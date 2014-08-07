# coding: utf-8
# General settings
default[:magento][:url] = 'http://www.magentocommerce.com/downloads/assets/1.'\
                          '9.0.1/magento-1.9.0.1.tar.gz'
default[:magento][:dir] = '/var/www/magento'
default[:magento][:domain] = node['fqdn']
# Magento CE's sample data can be found here:
# 'http://www.magentocommerce.com/downloads/assets/1.9.0.0/magento-sample-dat'\
# 'a-1.9.0.0.tar.gz'
# If you are using a version of Magento Community Edition older than 1.9.0.0,
# you will need to use a version of sample data that is compatible with your
# version.
default[:magento][:sample_data_url] = ''
default[:magento][:run_type] = 'store'
default[:magento][:run_codes] = []
default[:magento][:session][:save] = 'db'
default[:magento][:user] = 'magento'

# Required packages
case node['platform_family']
when 'rhel', 'fedora'
  default[:magento][:packages] = %w(php-cli php-common php-curl php-gd
                                    php-mcrypt php-mysql php-pear php-apc
                                    php-xml)
else
  default[:magento][:packages] = %w(php5-cli php5-common php5-curl php5-gd
                                    php5-mcrypt php5-mysql php-pear php-apc)
end

# Web Server
default[:magento][:webserver] = 'nginx'
default[:magento][:http_port] = 80
default[:magento][:https_port] = 443
default[:magento][:nginx][:send_timeout] = 60
default[:magento][:nginx][:proxy_read_timeout] = 60

default['php-fpm']['pools'] = [
  {
    name: 'magento',
    listen: '127.0.0.1:9001',
    allowed_clients: ['127.0.0.1'],
    user: node[:magento][:user],
    group: node[node[:magento][:webserver]][:group],
    process_manager: 'dynamic',
    max_children: 50,
    start_servers: 5,
    min_spare_servers: 5,
    max_spare_servers: 35,
    max_requests: 500
  }
]

# Web Server SSL Settings
default[:magento][:cert_name] = "#{node[:magento][:domain]}.pem"

# Credentials
::Chef::Node.send(:include, Opscode::OpenSSL::Password)

default[:magento][:database] = 'mysql'

default[:magento][:db][:host] = 'localhost'
default[:magento][:db][:database] = 'magento'
default[:magento][:db][:username] = 'magentouser'
set_unless[:magento][:db][:password] = secure_password
default[:magento][:db][:acl] = 'localhost'
