define omd::site::users (
  $site = $title,
  $managed_users = {},
  $enable_omdadmin = true,
  $automation_user = nil,
  $automation_secret_file = nil,
  $automation_secret = nil,
  $omd_host_url = '127.0.0.1',
  $script_dir = '/opt/omd/puppet'
) {
  require omd::site::user_scripts

  $ruby = "/usr/bin/ruby"
  $userhash = "/opt/omd/sites/${site}/puppet/userhash"
  $contacts = "/opt/omd/sites/${site}etc/check_mk/conf.d/wato/contacts.mk"
  $htpasswd = "/opt/omd/sites/${site}/etc/htpasswd"
  $serials = "/opt/omd/sites/${site}/etc/auth.serials"
  $users = "/opt/omd/sites/${site}/etc/check_mk/multisite.d/wato/users.mk"

  # If default omdadmin user is desired merge into user hash
  if $enable_omdadmin {
    $merged_users = merge($managed_users, {
      'omdadmin' => {
        'password' => '$6$B3mYW$s9gJpcn7V9miaCDUgxZCWj/RucgV7P63tGsYouik6HzSI9u8hG8qt4NZp5xhIFf2ZPS8HdGTW7Axh1RhIsNhs0',
        'roles' => ['admin'],
        'locked' => 'False',
      }
    })
  }
  else {
    $merged_users = $managed_users
  }

  file { 'hashDir':
    ensure => directory,
    path   => "/opt/omd/sites/${site}/puppet",
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    before => File['userHash'],
  }

  file { 'userHash':
    ensure  => present,
    path    => "/opt/omd/sites/${site}/puppet/userhash",
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => "${merged_users}",
    notify  => [ Exec['activateChanges.rb'], Exec['contacts.rb'],
                Exec['htpasswd.rb'], Exec['serials.rb'], Exec['users.rb'] ],
  }

  if $automation_secret_file != nil {
    $secret = "-f ${automation_secret_file}"
  }
  elsif $automation_secret != nil {
    $secret = "-p ${automation_secret}"
  }
  else {
    fail('Automation user needs to have a secret file or its password specified')
  }

### TODO: find a way to get username of modified users
  exec { 'contacts.rb':
    command     => "${ruby} ${script_dir}/contacts.rb -u ${userhash} -f ${contacts}",
    refreshonly => true,
    notify      => Exec['activateChanges.rb'],
  }

  exec { 'htpasswd.rb':
    command     => "${ruby} ${script_dir}/htpasswd.rb -u ${userhash} -f ${htpasswd}",
    refreshonly => true,
    notify      => Exec['activateChanges.rb'],
  }

  exec { 'serials.rb':
    command     => "${ruby} ${script_dir}/serials.rb -u ${userhash} -f ${serials}",
    refreshonly => true,
    notify      => Exec['activateChanges.rb'],
  }

  exec { 'users.rb':
    command     => "${ruby} ${script_dir}/users.rb -u ${userhash} -f ${users}",
    refreshonly => true,
    notify      => Exec['activateChanges.rb'],
  }

  exec { 'activateChanges.rb':
    command     => "${ruby} ${script_dir}/activateChanges.rb -u ${automation_user} -o ${site} -s ${omd_host_url} ${secret}",
    refreshonly => true,
  }
}
