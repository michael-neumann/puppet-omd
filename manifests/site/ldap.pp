define omd::site::ldap (
  $site = $title,
  $ldap_server,
  $ldap_bind_dn,
  $ldap_bind_pw,
  $ldap_group_dn,
  $ldap_user_dn,
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
    owner => $site,
    group => $site,
    mode  => '0660',
  }

  file_line { 'ldap_cache_livetime':
    ensure  => present,
    line    => 'ldap_cache_livetime = 300',
    match   => 'ldap_cache_livetime',
    path    => $ldap_file,
    require => File[$ldap_file],
  }

  file_line { 'ldap_connection':
    ensure  => present,
    line    => "ldap_connection = {'bind': ('${ldap_bind_dn}', '${ldap_bind_pw}'), 'connect_timeout': 2.0, 'page_size': 1000, 'port': ${ldap_port}, 'server': '${ldap_server}', 'type': 'ad', 'version': 3}",
    match   => 'ldap_connection',
    path    => $ldap_file,
    require => File[$ldap_file],
  }

  file_line { 'ldap_groupspec':
    ensure  => present,
    line    => "ldap_groupspec = {'dn': '${ldap_group_dn}', 'scope': 'sub'}",
    match   => 'ldap_groupspec',
    path    => $ldap_file,
    require => File[$ldap_file],
  }

  file_line { 'ldap_user_spec':
    ensure  => present,
    line    => "ldap_userspec = {'dn': '${ldap_user_dn}', 'filter': '${filter_real}', 'scope': 'sub', 'user_id_umlauts': 'replace'}",
    match   => 'ldap_user_spec',
    path    => $ldap_file,
    require => File[$ldap_file],
  }

  file_line { 'user_connectors':
    ensure  => present,
    line    => 'user_connectors = [\'htpasswd\', \'ldap\']',
    match   => 'user_connectors',
    path    => $ldap_file,
    require => File[$ldap_file],
  }

  # Enable multisite cookie auth
  # TODO flag to manage this?
  omd::site::config_variable { "${site} - MULTISITE_COOKIE_AUTH = on": }
}

#TODO exec
