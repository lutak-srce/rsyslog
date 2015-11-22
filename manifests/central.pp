#
# = Class: rsyslog::central
#
# This class manages separate rsyslog service that drops
# privileges and acts as central logging system.
class rsyslog::central (
  $service          = 'rsyslog-central',
  $syslogd_options  = '-c 5',
  $config_file      = '/etc/rsyslog-central.conf',
  $config_template  = 'rsyslog/central.conf.erb',
  $datadir          = '/var/lib/syslog',
  $user             = 'rsyslog',
  $group            = 'rsyslog',
  $uid              = '98',
  $gid              = '98',
  $tcp_port         = '10514',
  $udp_port         = '514',
  $file_create_mode = '0640',
  $dir_create_mode  = '0750',
  $umask            = '0077',
  $status           = 'enabled',
) {
  include ::rsyslog

  ### Input parameters validation
  validate_re($status,  ['enabled','disabled','running','stopped','activated','deactivated','unmanaged'], 'Valid values are: enabled, disabled, running, stopped, activated, deactivated and unmanaged')

  $service_enable = $status ? {
    'enabled'     => true,
    'disabled'    => false,
    'running'     => undef,
    'stopped'     => undef,
    'activated'   => true,
    'deactivated' => false,
    'unmanaged'   => undef,
  }
  $service_ensure = $status ? {
    'enabled'     => 'running',
    'disabled'    => 'stopped',
    'running'     => 'running',
    'stopped'     => 'stopped',
    'activated'   => undef,
    'deactivated' => undef,
    'unmanaged'   => undef,
  }

  File {
    owner => root,
    group => root,
    mode  => '0644',
  }

  file { $datadir :
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  file { "/etc/init.d/${service}" :
    mode   => '0755',
    source => 'puppet:///modules/rsyslog/central.init'
  }

  file { "/etc/sysconfig/${service}" :
    content => template('rsyslog/central.sysconfig.erb'),
    notify  => Service[$service],
  }

  file { $config_file :
    content => template($config_template),
    notify  => Service[$service],
  }

  group { $user :
    ensure => present,
    gid    => $gid,
    system => true,
  }

  user { $group :
    ensure     => present,
    comment    => 'Central syslog user',
    uid        => $uid,
    gid        => $gid,
    system     => true,
    home       => $datadir,
    managehome => false,
    shell      => '/sbin/nologin',
  }

  file { '/etc/rsyslog-central.d':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    purge   => $::purge_dotd,
    require => Package['rsyslog'],
  }

  service { $service :
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => [
      Group[$group],
      User[$user],
      File['/etc/rsyslog-central.d'],
    ],
  }

}
