#!/usr/bin/ruby
require "net/http"
require "uri"
require 'optparse'

#
# This script is used to activate the manual changes made to check_mk's WATO configuration.
#
# For any changes to be activated a properly formated pending.log must be generated at:
# ( /opt/omd/sites/<omdsite>/var/check_mk/wato/log/pending.log )
# This script does not generate this log file and must be handled elsewhere.
#
# It should be noted that this script blindly activates any and all pending changes
# specified in the sites pending.log
#
# The prefered method of supplying the automation users secret is by providing the path
# to the automation.secret file typically located at:
# ( /opt/omd/sites/<omdsite>/var/check_mk/web/<username>/automation.secret )
#
# Written By: Garrett Rowell
# # Last Edit: 2-4-2016
#

options = {:username => nil, :password => nil, :omd_site => nil, :site_url => nil, :file => nil}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end

  opts.on('-u', '--username username', 'Username of the desired Automation user') do |username|
    options[:username] = username;
  end

  opts.on('-p', '--password password', 'The Automation users secret. Note this is inherently insecure, --secret-file is more prefered.') do |password|
    options[:password] = password;
  end

  opts.on('-f', '--secret-file file', 'The absolute path to the Automation users secret file.') do |file|
    options[:file] = file;
  end

  opts.on('-o', '--omd_site omd_site', 'The omd site to connect to') do |omd_site|
    options[:omd_site] = omd_site;
  end

  opts.on('-s', '--site_url site_url', 'The ip or url of omd host to connect to') do |site_url|
    options[:site_url] = site_url;
  end

  ARGV.push('-h') if ARGV.empty?
end.parse!

# if no site is specified set to default
if options[:omd_site] == nil
  options[:omd_site] = 'default'
end

# if no url for the omd host is spec assume its 127.0.0.1
if options[:site_url] == nil
  options[:omd_site] = '127.0.0.1'
end

# an automation username and secret must be provided for this to execute properly
if ( options[:username] != nil and ( options[:password] or options[:file] ) )
  # if the automation users automation.secret file is specified obtain the secret from there
  if options[:file] != nil
    file = File.open(options[:file].to_s, 'r')
    if File.exists?(file)
      secret = file.read.delete!("\n")
      file.close
    end
    # if automation secret is explicitly specified and automation.secret is not use the specified secret.
    # however using the automation users automation.secret file is always prefered
  elsif (options[:password] != nil and options[:file] == nil)
    secret = options[:password]
  end

  # use check_mk's automation api to activate our changes
  uri = URI.parse("http://#{options[:site_url]}/#{options[:omd_site]}/check_mk/webapi.py?action=activate_changes&_username=#{options[:username]}&_secret=#{secret}&mode=all&allow_foreign_changes=1")
  http = Net::HTTP.new(uri.host, uri.port)
  http.request(Net::HTTP::Get.new(uri.request_uri))
else
  exit 1
end
