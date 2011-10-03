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

unless File.exists?("#{node[:magento][:dir]}/installed.flag")
  user "#{node[:magento][:user]}" do
    comment "magento guy"
    home "#{node[:magento][:dir]}"
    system true
  end
  directory "#{node[:magento][:dir]}/app/etc" do
    owner "#{node[:magento][:user]}"
    group "www-data"
    mode "0755"
    action :create
    recursive true
  end
end

template "#{node[:magento][:dir]}/app/etc/local.xml" do
  source "local.xml.erb"
  mode "0600"
  owner "#{node[:magento][:user]}"
  group "www-data"
  variables(:database => node[:magento][:db])
end
