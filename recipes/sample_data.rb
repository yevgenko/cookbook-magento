include_recipe "magento::mysql"

unless File.exists?("#{node[:magento][:dir]}/sample_data.flag")

  remote_file "#{Chef::Config[:file_cache_path]}/magento-sample-data.tar.gz" do
    checksum node[:magento][:sample_data][:checksum]                           
    source node[:magento][:sample_data][:url]                                  
    mode "0644"                                                                
  end
  
  bash "magento-sample-data" do                                                
    cwd "#{Chef::Config[:file_cache_path]}"
    code <<-EOH
mkdir #{name}
cd #{name}
tar --strip-components 1 -xzf #{Chef::Config[:file_cache_path]}/magento-sample-data.tar.gz
mv media/* #{node[:magento][:dir]}/media/
chmod -R o+w  #{node[:magento][:dir]}/media
mv magento_sample_data*.sql data.sql 2>/dev/null
/usr/bin/mysql -u #{node[:magento][:db][:username]} -p#{node[:magento][:db][:password]} #{node[:magento][:db][:database]} < data.sql
cd ..
rm -rf #{name}
touch #{node[:magento][:dir]}/sample_data.flag
EOH
  end
end

