class omd::site::user_scripts {
  $script_dir = '/opt/omd/puppet'

  file { 'scriptDir':
    ensure => directory,
    path   => script_dir,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    before => [ File['activateChanges.rb'], File['contacts.rb'],
                File['htpasswd.rb'], File['serials.rb'], File['users.rb'] ],
  }

  file { 'activateChanges.rb':
    ensure => present,
    path   => "${script_dir}/activateChanges.rb",
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    source => 'puppet:///modules/omd/users/activateChanges.rb',
  }

  file { 'contacts.rb':
    ensure => present,
    path   => "${script_dir}/contacts.rb",
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    source => 'puppet:///modules/omd/users/contacts.rb',
  }

  file { 'htpasswd.rb':
    ensure => present,
    path   => "${script_dir}/htpasswd.rb",
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    source => 'puppet:///modules/omd/users/htpasswd.rb',
  }

  file { 'serials.rb':
    ensure => present,
    path   => "${script_dir}/serials.rb",
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    source => 'puppet:///modules/omd/users/serials.rb',
  }

  file { 'users.rb':
    ensure => present,
    path   => "${script_dir}/users.rb",
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    source => 'puppet:///modules/omd/users/users.rb',
  }

}
