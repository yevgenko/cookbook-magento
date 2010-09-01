include_recipe "magento"
include_recipe "nginx"

if node.has_key?("ec2")
  server_fqdn = node.ec2.public_hostname
else
  server_fqdn = node.fqdn
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
  openssl genrsa 2048 > #{server_fqdn}.key
  openssl req -batch -new -x509 -days 365 -key #{server_fqdn}.key -out #{server_fqdn}.crt
  cat #{server_fqdn}.crt #{server_fqdn}.key > #{server_fqdn}.pem
  EOH
  only_if { File.zero?("#{node[:nginx][:dir]}/ssl/#{server_fqdn}.pem") }
  action :nothing
end

cookbook_file "#{node[:nginx][:dir]}/ssl/#{server_fqdn}.pem" do
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

%w{magento magento_ssl}.each do |site|
  template "#{node[:nginx][:dir]}/sites-available/#{site}" do
    source "nginx-site.erb"
    owner "root"
    group "root"
    mode 0644
    variables(:server_fqdn => server_fqdn, :ssl => (site == "magento_ssl")?true:false)
  end
  nginx_site "#{site}" do
    notifies :restart, resources(:service => "nginx")
  end
end

execute "ensure correct permissions" do
  command "chown -R root:#{node[:nginx][:user]} #{node[:magento][:dir]} && chmod -R g+rw #{node[:magento][:dir]}"
  action :run
end
