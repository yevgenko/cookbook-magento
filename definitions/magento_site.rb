define :magento_site do

  include_recipe "nginx"

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

  bash "Drop default site" do
    cwd "#{node[:nginx][:dir]}"
    code <<-EOH
    rm -rf conf.d/default.conf
    EOH
    notifies :reload, resources(:service => "nginx")
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

end
