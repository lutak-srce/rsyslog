#
# = Class: rsyslog
#
# This class manages rsyslog
#
#
# == Parameters
#
# [*purge_dotd*]
#   Boolean. Default: false
#   If set to true, enables purge of unamanged files from rsyslog.d dir.
#
class rsyslog (
  $purge_dotd = false,
  $version    = present,
) {

  package { 'rsyslog': ensure => $version }

  file { '/etc/rsyslog.d':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    purge   => $purge_dotd,
    require => Package['rsyslog'],
  }

  service { 'rsyslog':
    ensure  => running,
    enable  => true,
    require => Package['rsyslog'],
  }

}
