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
    hash
  end
end

# gsub is removing the '{' & '}'s in the string then parsing the string into a nested hash
user_file = File.open(options[:users])
user_hash = user_file.read.tr("{}", "").to_h()

# parses the current htpasswd into a hash
File.open(options[:file], "r").read.each_line do |line|
  key,value = line.split ':',2
  htpasswd_hash[key] = value
end

# If htpasswd file doesn't reflect the information provided about managed users, change it to match.
# This will not alter unmanaged users
user_hash.to_a.each do |key, _value|
  if user_hash[key].key?('password') && user_hash[key]['password'] != ''
    # password specified && is not an empty string
    htpasswd_hash[key] = if user_hash[key].key?('locked') && user_hash[key]['locked'] == 'True'
                           # user is locked
                           '!' + user_hash[key]['password']
                         else
                           # user is not locked
                           user_hash[key]['password']
                         end
  elsif user_hash[key].key?('locked') && user_hash[key]['locked'] == 'True'
    htpasswd_hash[key] = '!'
  else
    puts key + ' doesnt have a password && is not locked :\'('
    exit 1
  end
end

# write the updated htpasswd file
fileWrite = File.open(options[:file], "w")
htpasswd_hash.sort.each do |key, value|
  fileWrite.puts key+':'+value
end
fileWrite.close
