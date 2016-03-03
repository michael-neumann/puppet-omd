# (private) install checks
class omd::client::checks::install {

  $plugin_path = $omd::client::checks::params::plugin_path
  # Requires that puppetlabs-stdlib is avaliable
  $puppet_statedir = "${::puppet_vardir}/state"
  $ruby_dir = $omd::client::checks::params::ruby_dir

  File {
    owner  => $omd::client::checks::params::file_owner,
    group  => $omd::client::checks::params::file_group,
    mode   => '0755',
  }

  # create dir for plugins
  $plugin_dirs = prefix(['/nagios', '/nagios/plugins'], $plugin_path)
  file { $plugin_dirs:
    ensure => directory,
  }

  # install checks
  # requires that ruby is installed and avaliable at /usr/bin/ruby
  file { 'check_puppet':
    path    => "${plugin_path}/nagios/plugins/check_puppet.rb",
    content => template('omd/check_puppet.erb'),
  }

  file { 'check_cert':
    path    => "${plugin_path}/nagios/plugins/check_cert.rb",
    content => template('omd/check_cert.erb'),
  }

}
