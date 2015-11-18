# == Class: omd::site::service_contactgroup
#
# This define assigns a contact group to a set of services/hosts.
# The contact group is implicitly created.
#
# === Parameters
#
# [*site*]
#   Site in which the service group will be created.
#   Type: string
#   Required parameter.
#
# [contact_group_name*]
#   The name of the contact group.
#   Type: string
#   Required parameter.
#
# [*contact_group_desc*]
#   The description of the contact group. If left undefined
#   the description will default to the name of the contact group.
#   Type: string
#   Optional parameter.
#   Defaults to undef.
#
# [*services*]
#   An array of service prefixes, used to identify which services
#   will be placed in the group. The strings are extended regexes.
#   For example, a check called "fs_/var/log" will match "fs" or ".*log",
#   but not "fs_/var/$". To select all services, pass either
#   an empty array or an array containing "ALL_SERVICES".
#   Type: array
#   Required parameter.
#
# [*filename*]
#   Name of the conf.d file which will contain this config.
#   Type: string
#   defaults to $title (with .mk appended as needed)
#
# [*hosts*]
#   The hosts with which to associate the check. To select all hosts,
#   pass an array containing "ALL_HOSTS". Mutually exclusive with $host_tags.
#   Either $hosts or $host_tags must be defined.
#   Type: array
#   defaults to undef
#
# [*host_tags*]
#   The tags with which to associate the check. Mutually exclusive with $hosts.
#   Note: a host must match ALL tags provided to be included in the group.
#   Either $hosts or $host_tags must be defined.
#   Type: array
#   defaults to undef
#
# === Examples
#
# omd::site::service_contactgroup { 'dba_fs':
#   site                      => 'default',
#   service_contactgroup_name => 'Filesystems',
#   host_tags                 => 'database',
#   services                  => ['fs'],
# }
#
# omd::site::service_contactgroup { 'noc_all':
#   site                      => 'default',
#   service_contactgroup_name => 'noc',
#   hosts                     => ['ALL_HOSTS'],
#   services                  => ['ALL_SERVICES'],
# }

define omd::site::service_contactgroup (
  $site,
  $contact_group_name,
  $services,
  $filename           = $title,
  $contact_group_desc = undef,
  $hosts              = undef,
  $host_tags          = undef,
) {

  validate_re($site, '^\w+$')
  validate_re($filename, '[^/\ ]')
  validate_string($contact_group_name)
  validate_array($services)

  if (($hosts == undef) and ($host_tags == undef)) {
    fail('Must define either $hosts or $host_tags')
  }

  if (($hosts != undef) and ($host_tags != undef)) {
    fail('$hosts and $host_tags are mutually exclusive options.')
  }

  if ($hosts != undef) {
    validate_array($hosts)
  } else {
    validate_array($host_tags)
  }

  # If a filename ends with .mk, use it
  # Otherwise, append
  if ($filename =~ /\.mk$/) {
    $filename_real = $filename
  } else {
    $filename_real = "${filename}.mk"
  }

  $path = "/opt/omd/sites/${site}/etc/check_mk/conf.d"

  file { "${path}/${filename_real}":
    ensure  => present,
    owner   => $site,
    group   => $site,
    mode    => '0644',
    content => template('omd/service_contactgroups.erb'),
    notify  => Exec["check_mk update site: ${site}"],
  }
}
