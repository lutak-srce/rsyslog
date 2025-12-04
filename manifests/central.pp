# @summary
#   Manifest for Central Rsyslog server
#
class rsyslog::central (
  $user             = 'rsyslog-central',
  $group            = 'rsyslog-central',
  $uid              = '698',
  $gid              = '698',
  $config_file      = '/etc/rsyslog-central.conf',
  $syslogd_options  = '',
  $tcp_port         = '10514',
  $udp_port         = '514',
  $file_create_mode = '0640',
  $dir_create_mode  = '0750',
  $umask            = '0027',
  $datadir          = '/var/lib/rsyslog-central',
) {

  group { 'rsyslog-central':
    ensure => present,
    name   => $group,
    gid    => $gid,
    system => true,
    notify => Service['rsyslog-central'],
  }

  user { 'rsyslog-central':
    ensure     => present,
    name       => $user,
    system     => true,
    uid        => $uid,
    gid        => $gid,
    shell      => '/sbin/nologin',
    home       => $datadir,
    managehome => false,
    comment    => 'System user for central syslog service',
    notify     => Service['rsyslog-central'],
  }

  File {
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    notify  => Service['rsyslog-central'],
  }

  file { '/var/lib/rsyslog-central':
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => false,
    seltype => 'var_log_t',
  }

  file { '/etc/sysconfig/rsyslog-central':
    content => template('rsyslog/rsyslog-central.sysconfig.erb'),
  }

  file { '/etc/rsyslog-central.conf':
    path    => $config_file,
    content => template('rsyslog/rsyslog-central.conf.erb'),
  }

  file { '/etc/rsyslog-central.d':
    ensure => directory,
    mode   => '0755',
    purge  => true,
  }

  file { '/etc/systemd/system/rsyslog-central.service':
    ensure  => file,
    content => template('rsyslog/rsyslog-central.service.erb'),
  }

  service { 'rsyslog-central':
    ensure => running,
    enable => true,
  }

}
