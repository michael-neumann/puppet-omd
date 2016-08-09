# (private) install checks
class omd::client::checks::install {

  $plugin_path = $omd::client::checks::params::plugin_path
  $puppet_statedir = "${::puppet_vardir}/state"

  if versioncmp($::puppetversion, '4') >= 0 {
    # Version 4.0.0 or newer
    $ruby_path = '#!/opt/puppetlabs/puppet/bin/ruby'
  }
  elsif versioncmp($::puppetversion, '4') < 0 {
    # Version 3.x.x or older
    $ruby_path = '#!/usr/bin/ruby'
  }

  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # create dir for plugins
  $plugin_dirs = prefix(['/nagios', '/nagios/plugins'], $plugin_path)
  file { $plugin_dirs:
    ensure => directory,
  }

  # install checks
  file { 'check_puppet':
    path    => "${plugin_path}/nagios/plugins/check_puppet.rb",
    content => template('omd/check_puppet.erb'),
  }

  file { 'check_cert':
    path    => "${plugin_path}/nagios/plugins/check_cert.rb",
    content => template('omd/check_cert.erb'),
  }

}
