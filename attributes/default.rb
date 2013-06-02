# General settings
default[:magento][:url] = "http://www.magentocommerce.com/downloads/assets/1.7.0.2/magento-1.7.0.2.tar.gz"
default[:magento][:dir] = "/var/www/magento"
default[:magento][:sample_data_url] = '' # http://www.magentocommerce.com/downloads/assets/1.6.1.0/magento-sample-data-1.6.1.0.tar.gz
default[:magento][:run_type] = "store"
default[:magento][:run_codes] = Array.new
default[:magento][:session]['save'] = 'db'

# Required packages
case node["platform_family"]
when "rhel", "fedora"
  default[:magento][:packages] = ['php-cli', 'php-common', 'php-curl', 'php-gd', 'php-mcrypt', 'php-mysql', 'php-pear', 'php-apc', 'php-xml']
else
  default[:magento][:packages] = ['php5-cli', 'php5-common', 'php5-curl', 'php5-gd', 'php5-mcrypt', 'php5-mysql', 'php-pear', 'php-apc']
end

# Web Server
default[:magento][:webserver] = 'nginx'

set['php-fpm']['pools'] = ["magento"]

set_unless['php-fpm']['pool']['magento']['listen'] = "127.0.0.1:9001"
set_unless['php-fpm']['pool']['magento']['allowed_clients'] = ["127.0.0.1"]
set_unless['php-fpm']['pool']['magento']['user'] = 'magento'
set_unless['php-fpm']['pool']['magento']['group'] = 'magento'
set_unless['php-fpm']['pool']['magento']['process_manager'] = "dynamic"
set_unless['php-fpm']['pool']['magento']['max_children'] = 50
set_unless['php-fpm']['pool']['magento']['start_servers'] = 5
set_unless['php-fpm']['pool']['magento']['min_spare_servers'] = 5
set_unless['php-fpm']['pool']['magento']['max_spare_servers'] = 35
set_unless['php-fpm']['pool']['magento']['max_requests'] = 500

# Credentials
::Chef::Node.send(:include, Opscode::OpenSSL::Password)

default[:magento][:db][:database] = "magento"
default[:magento][:db][:username] = "magentouser"
set_unless[:magento][:db][:password] = secure_password
