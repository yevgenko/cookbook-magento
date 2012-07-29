include_recipe "php-fpm"
include_recipe "magento"
include_recipe "nginx"

if node.has_key?("ec2")
  server_fqdn = node.ec2.public_hostname
else
  server_fqdn = node.fqdn
end

bash "Tweak FPM php.ini file" do
  cwd "/etc/php5/fpm"
  code <<-EOH
  sed -i 's/memory_limit = .*/memory_limit = 128M/' php.ini
  sed -i 's/;realpath_cache_size = .*/realpath_cache_size = 32K/' php.ini
  sed -i 's/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/' php.ini
  EOH
  notifies :restart, resources(:service => "php5-fpm")
end

directory "#{node[:nginx][:dir]}/ssl" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

bash "Create SSL Certificates" do
  cwd "#{node[:nginx][:dir]}/ssl"
  code <<-EOH
  umask 022
  openssl genrsa 2048 > magento.key
  openssl req -batch -new -x509 -days 365 -key magento.key -out magento.crt
  cat magento.crt magento.key > magento.pem
  EOH
  only_if { File.zero?("#{node[:nginx][:dir]}/ssl/magento.pem") }
  action :nothing
end

cookbook_file "#{node[:nginx][:dir]}/ssl/magento.pem" do
  source "cert.pem"
  mode 0644
  owner "root"
  group "root"
  notifies :run, resources(:bash => "Create SSL Certificates"), :immediately
end

%w{backend}.each do |file|
  cookbook_file "#{node[:nginx][:dir]}/conf.d/#{file}.conf" do
    source "nginx/#{file}.conf"
    mode 0644
    owner "root"
    group "root"
  end
end

%w{default ssl}.each do |site|
  template "#{node[:nginx][:dir]}/sites-available/#{site}" do
    source "nginx-site.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
      :path => "#{node[:magento][:dir]}",
      :ssl => (site == "ssl")?true:false
    )
  end
  nginx_site "#{site}" do
    notifies :reload, resources(:service => "nginx")
  end
end

execute "ensure correct ownership" do
  command "chown -R #{node[:magento][:user]}:#{node[:nginx][:user]} #{node[:magento][:dir]}"
  action :run
end
