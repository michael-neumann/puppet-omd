#!/usr/bin/ruby
require 'optparse'

#
# This script when provided a managed users hash and an omd sites htpasswd file will add the
# user(s) and their password to the file. If the user is desired to be locked this will handle that
# as well.
#
# A sites htpasswd file is typically located at:
# ( /opt/omd/sites/<omdsite>/etc/htpasswd )
#
#
# Written By: Garrett Rowell
# Last Edit: 2-16-2016
#

options = {:users => nil, :file => nil}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end

  opts.on('-u', '--users <file>', 'File containing hash of managed and user information represented as a string') do |users|
    options[:users] = users;
  end

  opts.on('-f', '--file <file>', 'Path to the omd sites htpasswd file') do |file|
    options[:file] = file;
  end

  ARGV.push('-h') if ARGV.empty?
end.parse!

htpasswd_hash = Hash.new()

# parses string into a nested hash
class String
  def to_h()
    array = self.split('}, ')
    hash = {}

    array.each do |e|
      key_value = e.split(' => {')
      key2 = key_value[1].split(/(,\s)(?!(?:(?:\w*\])|(?:\w*,)))/)
      key_value.each {hash[key_value[0]]=Hash.new()}
      key2.each do |e1|
        key3 = e1.split(' => ')
        hash[key_value[0]][key3[0]]=key3[1]
      end
    end
    return hash
  end
end

# gsub is removing the '{' & '}'s in the string then parsing the string into a nested hash
user_file = File.open(options[:users])
user_hash = user_file.read.gsub(/^{/, '').gsub(/}$/, '').gsub(/}$/, '').to_h()

# parses the current htpasswd into a hash
fileRead = File.open(options[:file], "r").read.each_line do |line|
  key,value = line.split ':',2
  htpasswd_hash[key] = value
end

# If htpasswd file doesn't reflect the information provided about managed users, change it to match.
# This will not alter unmanaged users
user_hash.to_a.each do |key, value|
  if user_hash[key].has_key?('password') and user_hash[key]['password'] != ''
    # password specified and is not an empty string
    if user_hash[key].has_key?('locked') and user_hash[key]['locked'] == 'True'
      # user is locked
      htpasswd_hash[key] = '!'+user_hash[key]['password']
    else
      # user is not locked
      htpasswd_hash[key] = user_hash[key]['password']
    end
  else
    # password not present or was empty string
    if user_hash[key].has_key?('locked') and user_hash[key]['locked'] == 'True'
      # user is locked
      htpasswd_hash[key] = '!'
    else
      puts key + ' doesnt have a password and is not locked :\'('
      exit 1
      # if the user has neither a password nor is locked... well this should never be the case
    end
  end
end

# write the updated htpasswd file
fileWrite = File.open(options[:file], "w")
htpasswd_hash.sort.each do |key, value|
  fileWrite.puts key+':'+value
end
fileWrite.close
