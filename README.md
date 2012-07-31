# Magento Cookbook

Collection of recipes to build app stack for the [Magento][] deployments with
[Chef][]

## Installation

Run the following commands with-in your [Chef Repository][]:

    knife cookbook site install magento
    knife cookbook upload magento

## Usage

NOTE: currently here is no recipes to deploy magento itself except
`[magento::sample]`, so, I encourage everyone to contribute deployment
workflows :)

1. first of all checkout the recipes available, see `metadata.rb`
2. decide the prefered frontend, i.e. nginx, apache, etc.
3. decide if you will put database and frontend on a single or different nodes
4. include the recipes where you want the app stack and database configured

For example, you could start with the following [Chef Roles][]:

    # roles/app.rb
    name "app"
    run_list "recipe[magento::nginx]"

    # roles/db.rb
    name "db"
    run_list "recipe[magento::mysql]"
    default_attributes "mysql" => {
    "bind_address" => "127.0.0.1",
    "tunable" => {
        "innodb_buffer_pool_size" => "1GB",
        "table_cache" => "1024",
        "query_cache_size" => "64M",
        "query_cache_limit" => "2M"
    }
    }

And then bootstrap [Rackspace Cloud Servers][] instance with:

    knife rackspace server create 'role[app],role[db]' --server-name magebox --image 49 --flavor 3

Or if you like to deploy sample site:

    knife rackspace server create 'recipe[magento::sample]' --server-name magebox --image 49 --flavor 3

See [Launch Cloud Instances with Knife][] for the reference.

## Hacking

The project commes with a helper tasks for bootstraping recipes in a sandbox
environment:

    bundle install
    bundle exec rake sandbox:init
    bundle exec rake sandbox:up

See complete list of the tasks available with:

    bundle exec rake -T

NOTE: The sandbox environment depends on [VirtualBox][] thru the [Vagrant][]
project. Please check [Vagrant][] manual and make sure you've correct version of
[VirtualBox][] installed.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[Magento]:http://www.magentocommerce.com/
[Chef]:http://www.opscode.com/chef/
[Chef Repository]:http://wiki.opscode.com/display/chef/Chef+Repository
[Chef Roles]:http://wiki.opscode.com/display/chef/Roles
[Rackspace Cloud Servers]:http://www.rackspace.com/cloud/cloud_hosting_products/servers/
[Launch Cloud Instances with Knife]:http://wiki.opscode.com/display/chef/Launch+Cloud+Instances+with+Knife
[VirtualBox]:https://www.virtualbox.org/
[Vagrant]:http://vagrantup.com/
