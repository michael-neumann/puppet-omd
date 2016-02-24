# == Define: omd::site::users
#
#   Manages check_mk user configuration for a specified omd site.
#   This will not interfere with the operation of wato, however
#   in doing so users cannot be deleted using this manifest,
#   they can only be locked
#
# === Parameters
#
# ==== Required
#
# [*managed_users*]
#   A nested hash of users and pertinent information
#   regarding each user. Valid keys are
#
# ..[*username*]
#     The username of a user to manage. Users in
#     this hash will either be created or managed by puppet.
#     NOTE: users not present in this hash will remain
#     unaltered as to still allow WATO configuration
#
# ....[*alias*]
#       An alias used for the user. If ommited,
#       defaults to the users username
#
# ....[*force_authuser*]
#       When this option is True, then the status GUI will only
#       display hosts and services that the user is a contact for
#       even if they have the permission for seeing all objects.
#
# ....[*force_authuser_webservice*]
#       When this option is checked, then the Multisite webservice
#       will only export hosts and services that the user is a contact for
#       even if he has the permission for seeing all objects.
#
# ....[*locked*]
#       Whether or not to lock the users account
#       Defaults to 'False'
#
# ....[*roles*]
#       Permissions can be assigned on very granular level so new Roles can
#       be created to provide more complex permissions. By default only the
#       admin role can configure permissions. OMD has 3 default Roles. These
#       are admin, guest and user. Admins have complete administrative control,
#       Users have some control over the objects they are assigned, and
#       Guests users are usually limited only viewing data.
#       If ommited defaults to none ie []
#
# ....[*email*]
#       Email address for the user which is used for notifications.
#       If ommited defaults to none ie ''
#
# ....[*pager*]
#       Phone or pager number used for notifications
#       If ommited defaults to none ie ''
#
# ....[*disable_notifications*]
#       When this option is True, notifications will be disabled for
#       the given user.
#       If ommited defaults to False
#
# ....[*contactgroups*]
#       Think of Contact Groups as your any other group: a container
#       for holding something. Contact groups allow users to view and/or
#       edit their hosts and services within Multisite but also to
#       receive alerts and notifications via email, sms, etc.
#       NOTE: This manifest does not manage contact groups. It only assigns
#       a user to one or more contact group(s).
#       If ommited defaults to none ie []
#
# ....[*start_url*]
#       Start-URL to display in main frame.
#       If ommited defaults to dashboard.py
#
# ....[*password*]
#       Password for the specified user.
#       NOTE: passwords must be in a format recgonized by apache.
#       Acceptable formats are:
#        -Plain Text
#        -Crypt
#        -SHA1
#        -MD5
#       For more information you can visit:
#       https://httpd.apache.org/docs/2.2/misc/password_encryptions.html
#
#       An example of generating a password using openssl from the
#       command line
#       openssl passwd -crypt -salt <mySalt> <myPassword>
#
# [*automation_user*]
#   The username of the check_mk automation user.
#   NOTE: This user needs to be created manually
#   before any users can be managed by this module
#
# ==== Optional
#
# [*omd_host_url*]
#   The url or ip of the omd host
#   Defaults to '127.0.0.1'
#
# [*enable_omdadmin*]
#   Whether to leave the default omdadmin user enabled.
#   True leaves the user enabled, False locks the user
#   Defaults to 'true'
#
# [*script_dir*]
#   The directory where the scripts for this module
#   will live. The directory will be created if it does
#   not already exist
#   Defaults to '/opt/omd/puppet'
#
# === Configuration Example
#
# ::omd::site::users { 'default':
#   enable_omdadmin => false,
#   automation_user => 'auto',
#   managed_users => {
#      admin1 => {
#       alias => 'admin1',
#       force_authuser => 'False',
#       force_authuser_webservice => 'False',
#       locked => 'False',
#       roles => ['admin'],
#       email => 'admin@test.com',
#       password => '126D8rSh5sjUE',
#     },
#     usertest => {
#       roles => ['user'],
#       locked => 'False',
#       password => 'bodKbcdGHUX7.',
#     }
#   }
# }
#

define omd::site::users (
  $site = $title,
  $managed_users = {},
  $enable_omdadmin = true,
  $automation_user = nil,
  $omd_host_url = '127.0.0.1',
  $script_dir = '/opt/omd/puppet'
) {
  require omd::site::user_scripts

  validate_hash($managed_users)
  validate_bool($enable_omdadmin)
  validate_string($automation_user)
  validate_absolute_path($script_dir)
  validate_re($omd_host_url, ['\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', '(?:w+\.)?\w+(?:\.\w+)?'])

  $ruby = "/usr/bin/ruby"
  $userhash = "/opt/omd/sites/${site}/puppet/userhash"
  $contacts = "/opt/omd/sites/${site}/etc/check_mk/conf.d/wato/contacts.mk"
  $htpasswd = "/opt/omd/sites/${site}/etc/htpasswd"
  $serials = "/opt/omd/sites/${site}/etc/auth.serials"
  $users = "/opt/omd/sites/${site}/etc/check_mk/multisite.d/wato/users.mk"
  $automation_file = "/opt/omd/sites/${site}/var/check_mk/web/${automation_user}/automation.secret"

  # If default omdadmin user is desired merge into user hash
  if $enable_omdadmin {
    $merged_users = merge($managed_users, {
      'omdadmin' => {
        'password' => 'om4jvonliTnHA',
        'roles' => ['admin'],
        'locked' => 'False',
      }
    })
  }
  else {
    $merged_users = merge($managed_users, {
      'omdadmin' => {
        'locked' => 'True',
      }
    })
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
    command     => "${ruby} ${script_dir}/activateChanges.rb -u ${automation_user} -o ${site} -s ${omd_host_url} -f ${automation_file}",
    refreshonly => true,
  }
}
