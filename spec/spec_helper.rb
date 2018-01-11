require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts
require 'rspec-puppet-utils'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |config|
  config.mock_framework = :rspec

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.hiera_config = File.expand_path(File.join(__FILE__, '../fixtures/hiera.yaml'))
  config.module_path  = File.join(fixture_path, 'modules')
  config.manifest_dir = File.join(fixture_path, 'manifests')
end

# puppet 3.x vardir. puppet_vardir fact comes from stdlib
add_custom_fact :puppet_vardir, '/var/lib/puppet'
add_custom_fact :concat_basedir, '/some_dir'
add_custom_fact :staging_http_get, 'wget'
