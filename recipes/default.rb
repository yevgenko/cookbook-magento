# coding: utf-8
unless File.exist?(File.join(node[:magento][:dir], '.installed'))

  require 'time'
  inst_date = Time.new.rfc2822

  # BOF: Initialization block
  case node['platform_family']
  when 'rhel', 'fedora'
    include_recipe 'yum'
    include_recipe 'yum-epel'
  else
    include_recipe 'apt'
  end

  enc_key = nil # magento encryption key
  webserver = node[:magento][:webserver]
  user = 'magento'
  group = node[webserver]['group']
  php_conf =  if platform?('centos', 'redhat')
                ['/etc', '/etc/php.d']
              else
                ['/etc/php5/fpm', '/etc/php5/conf.d']
              end

  user "#{user}" do
    comment 'magento guy'
    home node[:magento][:dir]
    system true
  end
  # EOF: Initialization block

  # Install php-fpm package
  include_recipe 'php-fpm'

  # Centos Polyfills
  package 'libmcrypt' if platform?('centos', 'redhat')

  # Install required packages
  node[:magento][:packages].each do |pkg|
    package pkg do
      action :upgrade
    end
  end

  # Ubuntu Polyfills
  if platform?('ubuntu', 'debian')
    bash 'Tweak CLI php.ini file' do
      cwd '/etc/php5/cli'
      code <<-EOH
      sed -i 's/memory_limit = .*/memory_limit = 128M/' php.ini
      sed -i 's/;realpath_cache_size = .*/realpath_cache_size = 32K/' php.ini
      sed -i 's/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/' php.ini
      EOH
    end
  end

  bash 'Tweak apc.ini file' do
    cwd "#{php_conf[1]}" # module ini files
    code <<-EOH
    grep -q -e 'apc.stat=0' apc.ini || echo "apc.stat=0" >> apc.ini
    EOH
  end

  bash 'Tweak FPM php.ini file' do
    cwd "#{php_conf[0]}" # php.ini location
    code <<-EOH
    sed -i 's/memory_limit = .*/memory_limit = 128M/' php.ini
    sed -i 's/;realpath_cache_size = .*/realpath_cache_size = 32K/' php.ini
    sed -i 's/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/' php.ini
    EOH
    notifies :restart, resources(service: 'php-fpm')
  end

  directory node[:magento][:dir] do
    owner user
    group group
    mode 0755
    action :create
    recursive true
  end

  magento_site

  # Fetch magento release
  unless node[:magento][:url].empty?
    remote_file "#{Chef::Config[:file_cache_path]}/magento.tar.gz" do
      source node[:magento][:url]
      mode 0644
    end
    execute 'untar-magento' do
      cwd node[:magento][:dir]
      command <<-EOH
      tar --strip-components 1 -xzf \
      #{Chef::Config[:file_cache_path]}/magento.tar.gz
      EOH
    end
  end

  # Setup Database
  # if Chef::Config[:solo]
  db_config = { host: 'localhost' }
  db_user = node[:magento][:db]
  # else
    # FIXME: data bags search throwing 404 error: Net::HTTPServerException
    # db_config = search(:db_config, "id:master").first ||
    #                                                    {:host => 'localhost'}
    # db_user = search(:db_users, "id:magento").first || node[:magento][:db]
    # enc_key = search(:magento, "id:enckey").first
  # end

  magento_database if db_config[:host] == 'localhost'

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
        /usr/bin/mysql -h #{db_config[:host]} -u #{db_user[:username]} \
        -p#{db_user[:password]} #{db_user[:database]} < data.sql
        cd ..
        rm -rf #{name}
        EOH
    end
  end

  # Generate local.xml file
  if enc_key
    template File.join(node[:magento][:dir], 'app/etc/local.xml') do
      source 'local.xml.erb'
      mode 0600
      owner node[:magento][:user]
      variables(
        db_config: db_config,
        db_user: db_user,
        enc_key: enc_key,
        session: node[:magento][:session],
        inst_date: inst_date
      )
    end
  end

  bash 'Ensure correct permissions & ownership' do
    cwd node[:magento][:dir]
    code <<-EOH
    chown -R #{user}:#{group} #{node[:magento][:dir]}
    chmod -R o+w media
    chmod -R o+w var
    EOH
  end

  bash 'Touch .installed flag' do
    cwd node[:magento][:dir]
    code <<-EOH
    echo '#{inst_date}' > #{node[:magento][:dir]}/.installed
    EOH
  end

end
