# (private) defaults for omd::client
class omd::client::params {

  $download_package = true
  $logwatch_install = false
  $xinetd_disable   = 'no'
  $check_only_from  = undef
  $hosts            = { 'default' => {} }
  $hosts_defaults   = {}

  case $::osfamily {
    'Debian': {
      $package_name     = 'check-mk-agent'
      $download_source  = 'http://mathias-kettner.de/download'
      $check_agent      = '/usr/bin/check_mk_agent'
      $user             = 'root'
      $group            = 'root'
    }
    'RedHat': {
      $package_name     = 'check_mk-agent'
      $download_source  = 'http://mathias-kettner.de/download'
      $check_agent      = '/usr/bin/check_mk_agent'
      $user             = 'root'
      $group            = 'root'
    }
    'FreeBSD': {
      $download_source = 'http://git.mathias-kettner.de/git/?p=check_mk.git;a=blob_plain;f=agents/check_mk_agent.freebsd;hb=refs/heads/'
      $check_agent     = '/usr/local/bin/check_mk_agent'
      $user            = 'root'
      $group           = 'wheel'
    }
    default: {
      fail("${::osfamily} not supported")
    }
  }

}
