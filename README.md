# Magento Cookbook

Collection of recipes to build app stack for the [Magento][] deployments with
[Chef][]

## Installation

### With Berkshelf

    echo "cookbook 'magento', '~> 0.7'" >> Berksfile
    berks install
    berks upload # if using with Chef Server

### With Chef Repository

Run the following commands with-in your [Chef Repository][]:

    knife cookbook site install magento
    knife cookbook upload magento

## Usage Examples

### Single Rackspace Cloud Server Instance

Bootstrap [Rackspace Cloud Servers][] instance with:

    knife rackspace server create --run-list 'recipe[magento]' --server-name magebox --image 125 --flavor 3

Navigate to the node URL or IP in your browser to complete [Magento][] installation.
NOTE: you might need to skip base url validation.

Default Mysql Credentials:

 * database: magento
 * user: magentouser
 * password: randombly generated, see magento -> db attributes under Chef Server dashboard

See [Launch Cloud Instances with Knife][] for the reference.

## Hacking

The project preconfigured with a helper tools for bootstraping cookbook in a
sandboxed environment, i.e. [VirtualBox][]

### Requirements

 * [Bundler][]: `gem install bundler`
 * [Berkshelf][]: `bundle install`
 * [Vagrant][] 1.1.0 and greater
 * Berkshelf plugin for Vagrant: `vagrant plugin install vagrant-berkshelf`
 * Omnibus plugin for Vagrant: `vagrant plugin install vagrant-omnibus`

### Bootstrap VirtualBox

#### With Ubuntu 12.04

    vagrant up

#### With CentOS 6.5

    VMBOX='centos65' vagrant up


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
