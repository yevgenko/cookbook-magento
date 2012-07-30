include_recipe "magento::nginx"
include_recipe "magento::mysql"

unless File.exists?("#{node[:magento][:dir]}/installed.flag")
  remote_file "#{Chef::Config[:file_cache_path]}/magento.tar.gz" do
    source "http://www.magentocommerce.com/downloads/assets/1.7.0.2/magento-1.7.0.2.tar.gz"
    mode "0644"
  end
  remote_file "#{Chef::Config[:file_cache_path]}/magento-sample-data.tar.gz" do
    source "http://www.magentocommerce.com/downloads/assets/1.6.1.0/magento-sample-data-1.6.1.0.tar.gz"
    mode "0644"
  end
  directory "#{node[:magento][:dir]}" do
    owner "#{node[:magento][:user]}"
    group "www-data"
    mode "0755"
    action :create
    recursive true
  end
  execute "untar-magento" do
    cwd node[:magento][:dir]
    command "tar --strip-components 1 -xzf #{Chef::Config[:file_cache_path]}/magento.tar.gz"
  end
  bash "magento-sample-data" do
    cwd "#{Chef::Config[:file_cache_path]}"
    code <<-EOH
mkdir #{name}
cd #{name}
tar --strip-components 1 -xzf #{Chef::Config[:file_cache_path]}/magento-sample-data.tar.gz
mv media/* #{node[:magento][:dir]}/media/
chmod -R o+w #{node[:magento][:dir]}/media
chmod -R o+w #{node[:magento][:dir]}/var
mv magento_sample_data*.sql data.sql 2>/dev/null
/usr/bin/mysql -u #{node[:magento][:db][:username]} -p#{node[:magento][:db][:password]} #{node[:magento][:db][:database]} < data.sql
cd ..
rm -rf #{name}
EOH
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
--url "#{node[:magento][:url]}" \
--skip_url_validation \
--use_rewrites "yes" \
--use_secure "no" \
--secure_base_url "#{node[:magento][:url]}" \
--use_secure_admin "no" \
--admin_firstname "Admin" \
--admin_lastname "Admin" \
--admin_email "admin@example.com" \
--admin_username "admin123" \
--admin_password "321nimda"
touch #{node[:magento][:dir]}/installed.flag
EOH
  end
end
