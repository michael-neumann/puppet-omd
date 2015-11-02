# == Class: omd::site::customer_check
#
# This define creates a custom_check which will run on the omd server.
# Custom checks are similar to the legacy_check configuration.
#
# === Parameters
#
# [*site*]
#   Site in which the check is to be installed.
#   Type: string
#   Required parameter.
#
# [*service_description*]
#   Description of the service which will appear in the check_mk interface.
#   Type: string
#   Required parameter.
#
# [*filename*]
#   Name of the conf.d file which will contain this config.
#   Type: string
#   defaults to $title (with .mk appended as needed)
#
# [*has_perfdata*]
#   Flag indicating whether or not this check additional perfdata.
#   Type: boolean
#   defaults to false
#
# [*command*]
#   The check command to execute. If left undef, this check will be a passive check.
#   Type: string
#   defaults to undef
#
# [*command_name*]
#   The internal name of the command. If left undef, it will be named 'check-mk-custom'.
#   Type: string
#   defaults to undef
#
# [*hosts*]
#   The hosts with which to associate the check. Mutually exclusive with $host_tags.
#   Either $hosts or $host_tags must be defined.
#   Type: array
#   defaults to undef
#
# [*host_tags*]
#   The tags with which to associate the check. Mutually exclusive with $hosts.
#   Either $hosts or $host_tags must be defined.
#   Type: array
#   defaults to undef
#
# === Examples
#
# omd::site::customer_check { 'check_webservers':
#   site                => 'default',
#   host_tags           => 'webservers',
#   service_description => 'Check HTTP',
#   command             => 'check_http -I \$HOSTADDRESS\$ -u /index.html -w 5 -c 10',
#   command_name        => 'check-webservers',
# }

define omd::site::custom_check (
  $site,
  $service_description,
  $filename     = $title,
  $has_perfdata = false,
  $command      = undef,
  $command_name = undef,
  $hosts        = undef,
  $host_tags    = undef,
) {

  validate_re($site, '^\w+$')
  validate_re($filename, '[^/\ ]')
  validate_bool($has_perfdata)
  validate_string($service_description)

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

  if ($command != undef) {
    validate_string($command)
  }

  if ($command_name != undef) {
    validate_string($command_name)
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
    content => template('omd/custom_check.erb'),
    notify  => Exec["check_mk update site: ${site}"],
  }
}
