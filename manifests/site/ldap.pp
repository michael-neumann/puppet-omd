define omd::site::ldap (
  $ldap_server,
  $ldap_bind_dn,
  $ldap_bind_pw,
  $ldap_group_dn,
  $ldap_user_dn,
  $site             = $title,
  $ldap_port        = '389',
  $ldap_user_filter = undef,
  $ldap_user_group  = undef,
) {

  if ($ldap_user_filter == undef) and ($ldap_user_group == undef) {
    fail('Either $ldap_user_filter or $ldap_user_group must be set')
  }

  if ($ldap_user_filter) and ($ldap_user_group) {
    fail('$ldap_user_filter and $ldap_user_group are mutually exclusive options.')
  }

  # Allow a custom filter to be defined, or just use a simple group by default
  if $ldap_user_filter {
    $filter_real = $ldap_user_filter
  } else {
    $filter_real = "(&(objectclass=user)(objectcategory=person)(memberOf=${ldap_user_group}))"
  }

  $ldap_file = "/opt/omd/sites/${site}/etc/check_mk/multisite.d/wato/global.mk"

  file { $ldap_file:
    ensure    => present,
    owner     => $site,
    group     => $site,
    mode      => '0660',
    show_diff => false,
    content   => template('omd/global.mk.erb'),
  }

  # Enable multisite cookie auth
  # TODO flag to manage this?
  omd::site::config_variable { "${site} - MULTISITE_COOKIE_AUTH = on": }
}

#TODO exec
