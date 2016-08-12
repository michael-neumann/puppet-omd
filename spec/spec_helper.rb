require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
require 'rspec-puppet-utils'
include RspecPuppetFacts
require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.mock_framework = :rspec

  config.default_facts = {
    :kernel          => 'Linux',
    :osfamily        => 'Debian',
    :operatingsystem => 'Debian',
    :lsbdistid       => 'Debian',
    :lsbdistcodename => 'wheezy',
    :concat_basedir  => '/var/lib/puppet/concat',
  }

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.hiera_config = File.expand_path(File.join(__FILE__, '../fixtures/hiera.yaml'))
end
