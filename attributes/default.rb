# General settings
default[:magento][:version] = "stable"
default[:magento][:downloader][:url] = "http://www.magentocommerce.com/downloads/assets/1.3.2.1/magento-downloader-1.3.2.1.tar.gz"
default[:magento][:downloader][:checksum] = "91ccdebf0403f0c328cb728b4cd19504"
set[:magento][:dir] = "/var/www/magento"
default[:magento][:db][:host] = "localhost"
default[:magento][:db][:database] = "magentodb"
default[:magento][:db][:username] = "magentouser"
default[:magento][:admin][:email] = "webmaster@localhost"
default[:magento][:admin][:user] = "admin"

default[:magento][:sample_data][:url] = "http://www.magentocommerce.com/downloads/assets/1.2.0/magento-sample-data-1.2.0.tar.gz"
default[:magento][:sample_data][:checksum] = "bb53b15c081e1f437ffb9a31178b9db8"

default[:magento][:server][:aliases] = Array.new
default[:magento][:server][:static_domains] = Array.new

::Chef::Node.send(:include, Opscode::OpenSSL::Password)

set_unless[:magento][:db][:password] = secure_password
set_unless[:magento][:admin][:password] = secure_password
