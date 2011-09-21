maintainer       "Yevgeniy Viktorov"
maintainer_email "yeevgen@gmail.com"
license          "Apache 2.0"
description      "Installing magento stack"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.3.1"
recipe           "magento", "Install magento"
recipe           "magento::mysql", "Create mysql database for magento"
recipe           "magento::sample_data", "Pre-populate magento with sample data"
recipe           "magento::apache2", "Install apache2 webserver for magento"
recipe           "magento::nginx", "Install nginx webserver for magento"

%w{ debian ubuntu }.each do |os|
  supports os
end

%w{ apache2 nginx mysql openssl php }.each do |cb|
  depends cb
end

attribute "magento/version",
  :display_name => "Magento download version",
  :description => "Version of Magento to download from the Magento site.",
  :default => "stable"

attribute "magento/downloader/url",
  :display_name => "Magento downloader URL",
  :description => "URL to magento downloader.",
  :default => "http://www.magentocommerce.com/downloads/assets/1.3.2.1/magento-downloader-1.3.2.1.tar.gz"

attribute "magento/downloader/checksum",
  :display_name => "Magento downloader tarball checksum",
  :description => "Checksum of the tarball for the magento downloader.",
  :default => "91ccdebf0403f0c328cb728b4cd19504"
  
attribute "magento/dir",
  :display_name => "Magento installation directory",
  :description => "Location to place magento files.",
  :default => "/var/www/magento"

attribute "magento/server/aliases",
  :display_name => "Magento domain aliases",
  :description => "Domain aliases magento can be serverd on",
  :default => ""

attribute "magento/server/static_domains",
  :display_name => "Magento static domains",
  :description => "Domains can be used to server static files",
  :default => ""

attribute "magento/server/secure_domain",
  :display_name => "Magento secure domain",
  :description => "Domain to serve magento over SSL",
  :default => ""

attribute "magento/db/database",
  :display_name => "Magento MySQL database",
  :description => "Magento will use this MySQL database to store its data.",
  :default => "magentodb"

attribute "magento/db/user",
  :display_name => "Magento MySQL user",
  :description => "Magento will connect to MySQL using this user.",
  :default => "magentouser"

attribute "magento/db/password",
  :display_name => "Magento MySQL password",
  :description => "Password for the Magento MySQL user.",
  :default => "randomly generated"

attribute "magento/admin/email",
  :display_name => "Magento Admin email",
  :description => "Email address of the Magento Administrator.",
  :default => "webmaster@localhost"

attribute "magento/admin/user",
  :display_name => "Magento Admin user",
  :description => "User to access Magento Administration panel.",
  :default => "admin"

attribute "magento/admin/password",
  :display_name => "Magento Admin password",
  :description => "Password for the Magento Administration.",
  :default => "randomly generated"
