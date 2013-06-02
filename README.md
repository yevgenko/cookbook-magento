# Magento Cookbook

Collection of recipes to build app stack for the [Magento][] deployments with
[Chef][]

## Installation

### With Chef Repository

Run the following commands with-in your [Chef Repository][]:

    knife cookbook site install magento
    knife cookbook upload magento

### With Berkshelf

    echo 'magento ~> 0.7' > Berksfile
    berks install

## Usage

### Standalone Node

Bootstrap [Rackspace Cloud Servers][] instance with:

    knife rackspace server create 'recipe[magento]' --server-name magebox --image 49 --flavor 3

Navigate to the node URL or IP in your browser to complete [Magento][] setup.

Default Mysql Credentials:

 * database: magento
 * user: magentouser
 * password: randombly generated, see under the node attributes under opscode
   dashboard

See [Launch Cloud Instances with Knife][] for the reference.

## Hacking

The project preconfigured with a helper tools for bootstraping cookbook in a
sandboxed environment, i.e. [VirtualBox][]

### Requirements

 * [Bundler][]: `gem install bundler`
 * [Berkshelf][]: `bundle install`
 * [Vagrant][] 1.1.0 and greater
 * Berkshelf plugin for Vagrant: `vagrant plugin install vagrant-berkshelf`

### Sandboxing with VirtualBox

    vagrant up

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
[Berkshelf]:http://berkshelf.com/
[Bundler]:http://gembundler.com/
