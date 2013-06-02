define :magento_database do

  include_recipe "mysql::server"

  # necessary for mysql gem installation
  package "make" do
    action :upgrade
  end

  gem_package "mysql" do
    action :install
  end

  execute "mysql-install-mage-privileges" do
    command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} < /etc/mysql/mage-grants.sql"
    action :nothing
  end

  template "/etc/mysql/mage-grants.sql" do
    path "/etc/mysql/mage-grants.sql"
    source "grants.sql.erb"
    owner "root"
    group "root"
    mode "0600"
    variables(:database => node[:magento][:db])
    notifies :run, resources(:execute => "mysql-install-mage-privileges"), :immediately
  end

  execute "create #{node[:magento][:db][:database]} database" do
    command "/usr/bin/mysqladmin -u root -p#{node[:mysql][:server_root_password]} create #{node[:magento][:db][:database]}"
    not_if do
      require 'rubygems'
      Gem.clear_paths
      require 'mysql'
      m = Mysql.new("localhost", "root", node[:mysql][:server_root_password])
      m.list_dbs.include?(node[:magento][:db][:database])
    end
  end

  # save node data after writing the MYSQL root password, so that a failed chef-client run that gets this far doesn't cause an unknown password to get applied to the box without being saved in the node data.
  unless Chef::Config[:solo]
    ruby_block "save node data" do
      block do
        node.save
      end
      action :create
    end
  end

end
