# coding: utf-8

include_recipe 'nginx'

Magento.create_ssl_cert(File.join(node[:nginx][:dir], 'ssl'),
                        node[:magento][:domain], node[:magento][:cert_name])

%w(backend).each do |file|
  cookbook_file File.join(node[:nginx][:dir], 'conf.d', "#{file}.conf") do
    source "nginx/#{file}.conf"
    mode 0644
    owner 'root'
    group 'root'
  end
end

bash 'Drop default site' do
  cwd node[:nginx][:dir]
  code <<-EOH
  rm -rf conf.d/default.conf
  EOH
  notifies :reload, resources(service: 'nginx')
end

%w(default ssl).each do |site|
  template File.join(node[:nginx][:dir], 'sites-available', site) do
    source 'nginx-site.erb'
    owner 'root'
    group 'root'
    mode 0644
    variables(
      path: node[:magento][:dir],
      ssl: (site == 'ssl') ? true : false,
      ssl_cert: File.join(node[:nginx][:dir], 'ssl',
                          node[:magento][:cert_name]),
      ssl_key: File.join(node[:nginx][:dir], 'ssl', node[:magento][:cert_name])
    )
  end
  nginx_site site do
    template nil
    notifies :reload, resources(service: 'nginx')
  end
end
