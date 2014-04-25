# coding: utf-8

node.set['apache']['default_modules'] = %w(status actions alias auth_basic
                                           authn_file authz_default
                                           authz_groupfile authz_host
                                           authz_user autoindex dir env mime
                                           negotiation setenvif ssl headers
                                           expires log_config logio fastcgi)
include_recipe 'apache2'

Magento.create_ssl_cert(File.join(node[:apache][:dir], 'ssl'),
                        node[:magento][:domain], node[:magento][:cert_name])

%w(default ssl).each do |site|
  web_app "#{site}" do
    template 'apache2-site.conf.erb'
    docroot node[:magento][:dir]
    server_name node[:magento][:domain]
    server_aliases node.fqdn
    ssl true if site == 'ssl'
    ssl_cert File.join(node[:apache][:dir], 'ssl', node[:magento][:cert_name])
    ssl_key File.join(node[:apache][:dir], 'ssl', node[:magento][:cert_name])
  end
end

%w(default 000-default).each do |site|
  apache_site "#{site}" do
    enable false
  end
end
