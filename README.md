Minecraft Environment
---------------------

This project creates a Minecraft Environment where you can set up
a server, select mods to load (soon), manage your player whitelist,
and so on.

Using Vagrant and Virtualbox, you may test changes to your server 
locally before deploying it to the actual system on the internet where
it will be hosted.

Prerequisites
-------------

    $ sudo apt-get install git-core vagrant
  
Vagrant 1.1.5 or later is required.  If you have an earlier version of
vagrant:

    $ wget http://files.vagrantup.com/packages/64e360814c3ad960d810456add977fd4c7d47ce6/vagrant_i686.deb
    $ sudo dpkg -i vagrant_i686.deb

For other vagrant downloads, see http://downloads.vagrantup.com/.

If you are using Virtualbox 4.1, you may see warnings.  To install Virtualbox 4.2:

     $ sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian precise contrib" >> /etc/apt/sources.list'
     $ wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
     $ sudo apt-get update
     $ sudo apt-get remove virtualbox
     $ sudo apt-get install virtualbox-4.2

Make sure that virtualbox is not running before you do this. See
https://www.virtualbox.org/wiki/Linux_Downloads for more information.

Customizing
-----------

To begin, first [fork](https://help.github.com/articles/fork-a-repo) the
Minecraft Environment project by clicking on the "fork" button in github.

Next, clone your copy of the project to your local machine:

    $ git clone git@github.com:YOURUSERNAME/minecraft-environment.git
    $ git remote add upstream https://github.com/greg-1-anderson/minecraft-environment.git

Create a branch to save your customizations in:

    $ git checkout -b MYBRANCHNAME

Edit the minecraft.pp file and customize to suit:

    $ gedit puppet/manifests/minecraft.pp
    $ git add .
    $ git commit -m "My customized server"
    $ git push --set-upstream origin MYBRANCHNAME

Later, if you want to pull in changes committed to the Minecraft Environment
project:

    $ git checkout master
    $ git pull upstream master
    $ git checkout MYBRANCHNAME
    $ git rebase master

Testing Locally
---------------

Create the virtual machine:

    $ vagrant up

If it comes up with no errors, ssh in to confirm that everything
looks okay:

    $ vagrant ssh

To re-apply the puppet manifests after making changes:

    $ vagrant provision

Alternately, `vagrant destroy` followed by `vagrant up` is a more
robust, but slower way to accomplish the same thing.

If you want to see more information about your provision run, set
the VAGRANT_LOG enviornment variable:

    $ VAGRANT_LOG=info vagrant provision

Then, run your Minecraft client and connect to the server at
10.20.30.40 (or whatever IP address you configured in minecraft.pp).

Deploying
---------

This project has been tested on Ubuntu 12.04 LTS.  Other distributions
may also work.

Puppet version 3 is required.  To install puppet:

    $ wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
    $ sudo dpkg -i puppetlabs-release-precise.deb
    $ sudo apt-get update
    $ sudo apt-get install puppet

Use ssh to open a shell on your remote server.  Use git clone to pull down 
your fork of the Minecraft environment, and switch to your branch.

Run puppet in standalone mode:

    $ sudo puppet apply --modulepath=modules:/etc/puppet/modules manifests/minecraft.pp

Everything should come up the same way that it did on the Vagrant box.

Modding
-------

This is a future feature.
