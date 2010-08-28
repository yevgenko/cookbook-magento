include_recipe "mysql::client"

if node.has_key?("ec2")
  server_fqdn = node.ec2.public_hostname
else
  server_fqdn = node.fqdn
end

if "webmaster@localhost" == node[:magento][:admin][:email]
  admin_email = "webmaster@#{server_fqdn}"
else
  admin_email = node[:magento][:admin][:email]
end

# Required extensions
%w{php5-cli php5-common php5-curl php5-gd php5-mcrypt php5-mysql php-pear}.each do |package|
  package "#{package}" do
    action :upgrade
  end
end

# Mostly to extend memory_limit which 32Mb on Debian
cookbook_file "/etc/php5/cli/php.ini" do
  source "cli-php.ini"
  mode 0644
  owner "root"
  group "root"
end

remote_file "#{Chef::Config[:file_cache_path]}/magento-downloader.tar.gz" do
  checksum node[:magento][:downloader][:checksum]
  source node[:magento][:downloader][:url]
  mode "0644"
end

directory "#{node[:magento][:dir]}" do
  owner "root"
  group "www-data"
  mode "0755"
  action :create
  recursive true
end

execute "untar-magento" do
  cwd node[:magento][:dir]
  command "tar --strip-components 1 -xzf #{Chef::Config[:file_cache_path]}/magento-downloader.tar.gz"
end

execute "pear-setup" do
  cwd node[:magento][:dir]
  command "./pear mage-setup ."
end

execute "magento-install-core" do
  cwd node[:magento][:dir]
  command "./pear install magento-core/Mage_All_Latest-#{node[:magento][:version]}"
end

bash "magento-install-site" do
  cwd node[:magento][:dir]
  code <<-EOH
rm -f app/etc/local.xml
php -f install.php -- \
--license_agreement_accepted "yes" \
--locale "en_US" \
--timezone "America/Los_Angeles" \
--default_currency "USD" \
--db_host "#{node[:magento][:db][:host]}" \
--db_name "#{node[:magento][:db][:database]}" \
--db_user "#{node[:magento][:db][:username]}" \
--db_pass "#{node[:magento][:db][:password]}" \
--url "http://#{server_fqdn}/" \
--skip_url_validation \
--use_rewrites "yes" \
--use_secure "yes" \
--secure_base_url "" \
--use_secure_admin "yes" \
--admin_firstname "Admin" \
--admin_lastname "Admin" \
--admin_email "#{admin_email}" \
--admin_username "#{node[:magento][:admin][:user]}" \
--admin_password "#{node[:magento][:admin][:password]}"
EOH
end

template "#{node[:magento][:dir]}/app/etc/local.xml" do      
  source "local.xml.erb"                                           
  mode "0600"                                                      
  owner "root"
  group "root"
  variables(:database => node[:magento][:db])
end
