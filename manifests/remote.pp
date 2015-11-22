#
# = Define: rsyslog::remote
#
# This define manages conf file for remote logging feature
#
# == Parameters
#
# [*protocol*]
#   String. Default: tcp
#   Defines the transmission protocol used for log messages. TCP or UDP
#
# [*forward*]
#   String. Default: *.*
#   Defines syslog facility and log level of messages that will be
#   transmitted to remote log server.
#
# [*server*]
#   String.
#   IP address or FQDN of remote log server.
#
# [*port*]
#   Integer.
#   Port of remote log server.
#
define rsyslog::remote (
  $server,
  $port,
  $protocol = 'udp',
  $forward  = '*.*',
) {
  include ::rsyslog

  file { "/etc/rsyslog.d/remote_logging_${title}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('rsyslog/remote_logging.conf.erb'),
    notify  => Service['rsyslog'],
  }

}
# vi: nowrap
