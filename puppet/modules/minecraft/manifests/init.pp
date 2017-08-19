# Class: minecraft
#
# This class installs and configures a Minecraft server
#
# Parameters:
# - $user: The user account for the Minecraft service
# - $group: The user group for the Minecraft service
# - $homedir: The directory in which Minecraft stores its data
# - $version: The version of the Minecraft server to install
# - $distribution: Which flavor of server to install: minecraft|vanilla or bukkit/craftbukkit
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
  $distribution  = 'minecraft',
  $version       = 'latest',
  $manage_java   = true,
  $manage_screen = true,
  $manage_curl   = true,
  $heap_size     = 2048,
  $heap_start    = 512,
)
{
  $minecraft_version = $version ? {
    # Ideally, we look this up from
    # https://s3.amazonaws.com/Minecraft.Download/versions/versions.json
    # n.b. new URL for that resource is:
    # https://launchermeta.mojang.com/mc/game/version_manifest.json
    latest => '1.12.1',
    default => $version,
  }

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
      before => File["${homedir}/minecraft_server.jar"],
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

  s3file { "${homedir}/minecraft_server_$minecraft_version.jar":
    # Maybe use latest:
    # http://s3.amazonaws.com/Minecraft.Download/launcher/Minecraft.jar
    # http://s3.amazonaws.com/Minecraft.Download/versions/1.12.1/minecratft_server.1.12.1.jar
    # Minecraft.Download/versions/$version/minecratft_server.$version.jar
    source  => "Minecraft.Download/versions/$minecraft_version/minecraft_server.$minecraft_version.jar",
    require => User[$user],
  }

  file { "${homedir}/minecraft_server.jar":
    ensure => link,
    target  => "${homedir}/minecraft_server_$minecraft_version.jar",
    require => S3File["${homedir}/minecraft_server_$minecraft_version.jar"],
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
    require   => [ File['/etc/init.d/minecraft'], File["${homedir}/minecraft_server.jar"], ],
    subscribe => File["${homedir}/minecraft_server.jar"],
  }
}
