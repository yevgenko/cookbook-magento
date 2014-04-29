# coding: utf-8

installed_file = '/root/.magento.db.installed'

unless File.exist?(installed_file)

  include_recipe 'mysql::server'
  include_recipe 'mysql::client'
  include_recipe 'mysql-chef_gem'

  root_password = node[:mysql][:server_root_password]
  db_config = node[:magento][:db]

  execute 'mysql-install-mage-privileges' do
    command <<-EOH
    /usr/bin/mysql -u root -p#{root_password} < \
    /etc/mysql/mage-grants.sql
    EOH
    action :nothing
  end

  template '/etc/mysql/mage-grants.sql' do
    path '/etc/mysql/mage-grants.sql'
    source 'grants.sql.erb'
    owner 'root'
    group 'root'
    mode 0600
    variables(database: node[:magento][:db])
    notifies :run, resources(execute: 'mysql-install-mage-privileges'),
             :immediately
  end

  execute "create #{node[:magento][:db][:database]} database" do
    command <<-EOH
    /usr/bin/mysqladmin -u root -p#{root_password} \
    create #{node[:magento][:db][:database]}
    EOH
    not_if do
      require 'rubygems'
      Gem.clear_paths
      require 'mysql'
      m = Mysql.new('localhost', 'root', root_password)
      m.list_dbs.include?(node[:magento][:db][:database])
    end
  end

  # Save node data after writing the MYSQL root password, so that a failed
  # chef-client run that gets this far doesn't cause an unknown password to get
  # applied to the box without being saved in the node data.
  unless Chef::Config[:solo]
    ruby_block 'save node data' do
      block do
        node.save
      end
      action :create
    end
  end

  # Import Sample Data
  unless node[:magento][:sample_data_url].empty?
    include_recipe 'mysql::client'

    remote_file File.join(Chef::Config[:file_cache_path],
                          'magento-sample-data.tar.gz') do
      source node[:magento][:sample_data_url]
      mode 0644
    end

    bash 'magento-sample-data' do
      cwd "#{Chef::Config[:file_cache_path]}"
      code <<-EOH
        mkdir #{name}
        cd #{name}
        tar --strip-components 1 -xzf \
        #{Chef::Config[:file_cache_path]}/magento-sample-data.tar.gz
        mv media/* #{node[:magento][:dir]}/media/

        mv magento_sample_data*.sql data.sql 2>/dev/null
        /usr/bin/mysql -h #{db_config[:host]} -u #{db_config[:username]} \
        -p#{db_config[:password]} #{db_config[:database]} < data.sql
        cd ..
        rm -rf #{name}
      EOH
    end
  end
end
