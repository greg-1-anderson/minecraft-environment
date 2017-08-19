#
# Minecraft environment for managing a server.
#
# This environment may be tested locally using Vagrant,
# or may be deployed to a remote server.  See the README.md file.
#
group { "puppet":
  ensure => "present",
}
File { owner => 0, group => 0, mode => 0644 }

exec { "apt-update":
    command => "/usr/bin/apt-get update",
}

Exec["apt-update"] -> Package <| |>

# Instantiate the 'minecraft' class to do our basic server setup
class { 'minecraft': }

# Declare the operator (or operators)
minecraft::op { "byron358": }

# List the whitelisted players
minecraft::whitelist { "flaryo": }

# Define any server properties (e.g. message of the day)
# desired for the Minecraft server
minecraft::server_prop { 'motd':
  value => "Welcome to the Minecraft Server",
}

# This message of the day file is seen when ssh-ing
# in to the Minecraft server.
file { '/etc/motd':
  content => "Welcome to the Minecraft Server shell.\n"
}

# Set up a webserver front-end for our site.
#apache_httpd { 'prefork':
#    # todo: use named virtual host?
#    documentroot => '/srv/www/minecraft',
#    ssl     => true,
#    modules => [
#        'mime',
#        'dir',
#        'alias',
#        'rewrite',
#        'proxy',
#    ],
#    welcome => false,
#}

