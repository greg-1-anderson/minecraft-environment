# Class: minecraft
#
# This class installs and configures a Minecraft server
#
# Parameters:
# - $user: The user account for the Minecraft service
# - $group: The user group for the Minecraft service
# - $homedir: The directory in which Minecraft stores its data
# - $version: The version of the Minecraft server to install
# - $manage_java: Should this module manage the `java` package?
# - $manage_screen: Should this module manage the `screen` package?
# - $manage_curl: Should this module manage the `curl` package?
# - $heap_size: The maximum Java heap size for the Minecraft service in megabytes
# - $heap_start: The initial Java heap size for the Minecraft service in megabytes
#
# Sample Usage:
#
#  class { 'minecraft':
#    user      => 'mcserver',
#    group     => 'mcserver',
#    heap_size => 4096,
#  }
#
class minecraft(
  $user          = 'mcserver',
  $group         = 'mcserver',
  $homedir       = '/opt/minecraft',
  $version       = '1.7.2',
  $manage_java   = true,
  $manage_screen = true,
  $manage_curl   = true,
  $heap_size     = 2048,
  $heap_start    = 512,
)
{
  if $manage_java {
    class { 'java':
      distribution => 'jre',
      before       => Service['minecraft'],
    }
  }

  if $manage_screen {
    package {'screen':
      before => Service['minecraft']
    }
  }

  if $manage_curl {
    package {'curl':
      before => S3file["${homedir}/minecraft_server.jar"],
    }
  }

  group { $group:
    ensure => present,
  }

  user { $user:
    gid        => $group,
    home       => $homedir,
    managehome => true,
  }

  s3file { "${homedir}/minecraft_server.jar":
    source  => "Minecraft.Download/versions/$version/minecraft_server.$version.jar",
    require => User[$user],
  }

  file { "${homedir}/ops.txt":
    ensure => present,
    owner  => $user,
    group  => $group,
    mode   => '0664',
  } -> Minecraft::Op<| |>

  file { "${homedir}/banned-players.txt":
    ensure => present,
    owner  => $user,
    group  => $group,
    mode   => '0664',
  } -> Minecraft::Ban<| |>

  file { "${homedir}/banned-ips.txt":
    ensure => present,
    owner  => $user,
    group  => $group,
    mode   => '0664',
  } -> Minecraft::Ipban<| |>

  file { "${homedir}/white-list.txt":
    ensure => present,
    owner  => $user,
    group  => $group,
    mode   => '0664',
  } -> Minecraft::Whitelist<| |>

  file { "${homedir}/server.properties":
    ensure => present,
    owner  => $user,
    group  => $group,
    mode   => '0664',
  } -> Minecraft::Server_prop<| |>

  # determine whether to use chkconfig or sysv-rc-conf package
  $rc_config = $operatingsystem ? {
    /(Debian|Ubuntu)/ => "sysv-rc-conf",
    default => "chkconfig",
  }

  package { "$rc_config":
      ensure => "present",
      alias  => "rc-config",
  }

  file { '/etc/init.d/minecraft':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('minecraft/minecraft_init.erb'),
    require => Package['rc-config'],
  }

  service { 'minecraft':
    ensure    => running,
    enable    => true,
    require   => [ File['/etc/init.d/minecraft'], S3File["${homedir}/minecraft_server.jar"], ],
    subscribe => S3File["${homedir}/minecraft_server.jar"],
  }
}
