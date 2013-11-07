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

  $ sudo apt-get install git-core vagrant puppet

Customizing
-----------

To begin, first [fork](https://help.github.com/articles/fork-a-repo) the
Minecraft Environment project by clicking on the "fork" button in github.

Next, clone your copy of the project to your local machine:

    $ git clone git@github.com:YOURUSERNAME/minecraft-environment.git

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
    $ git pull origin master
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

Use ssh to open a shell on your remote server, which ideally should
also be running Ubuntu 12.04 LTS, just like your Vagrant box.  Use 
git clone to pull down your fork of the Minecraft environment, and 
switch to your branch.

Run puppet in standalone mode:

    $ sudo puppet apply --modulepath=modules:/etc/puppet/modules manifests/minecraft.pp

Everything should come up the same way that it did on the Vagrant box.

Modding
-------

This is a future feature.
