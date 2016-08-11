# (private) defaults for omd::client::checks
class omd::client::checks::params(
  $omd_master_vardir = $::puppet_vardir
){

  $mrpe_config = '/etc/check_mk/mrpe.cfg'
  $plugin_path = '/usr/local/lib'

  case $::osfamily {
    'Debian': {
      $file_owner = 'root'
      $file_group = 'root'
      $ruby_os    = '/usr/bin/ruby'
    }
    'RedHat': {
      $file_owner = 'root'
      $file_group = 'root'
      $ruby_os    = '/usr/bin/ruby'
    }
    'FreeBSD': {
      $file_owner = 'root'
      $file_group = 'wheel'
      $ruby_os    = '/usr/local/bin/ruby'
    }
    default: {
      fail("${::osfamily} not supported")
    }
  }

}
