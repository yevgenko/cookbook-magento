include_recipe "magento::mysql"

remote_file "#{Chef::Config[:file_cache_path]}/magento-sample-data.tar.gz" do
  checksum node[:magento][:sample_data][:checksum]                           
  source node[:magento][:sample_data][:url]                                  
  mode "0644"                                                                
end                                                                          
                                                                             
directory "#{Chef::Config[:file_cache_path]}/magento-sample-data" do         
  action :create                                                             
end                                                                          
                                                                             
bash "magento-sample-data" do                                                
  cwd "#{Chef::Config[:file_cache_path]}/magento-sample-data"                
  code <<-EOH                                                                
tar --strip-components 1 -xzf #{Chef::Config[:file_cache_path]}/magento-sample-data.tar.gz
mv media/* #{node[:magento][:dir]}/media/
chmod -R o+w  #{node[:magento][:dir]}/media
mv magento_sample_data*.sql data.sql 2>/dev/null
/usr/bin/mysql -u #{node[:magento][:db][:username]} -p#{node[:magento][:db][:password]} #{node[:magento][:db][:database]} < data.sql
EOH
end                                                              
                                                                 
directory "#{Chef::Config[:file_cache_path]}/magento-sample-data" do
  recursive true                                                 
  action :delete                                                 
end                                                              
