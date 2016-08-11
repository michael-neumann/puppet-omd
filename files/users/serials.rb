#!/usr/bin/ruby
require 'optparse'

#
# This script when provided a managed users hash and an omd sites auth.serials file will add the
# user(s) with the default serial if the user(s) are not currently present in the file.
#
# A sites auth.serials file is typically located at:
# ( /opt/omd/sites/<omdsite>/etc/auth.serials )
#
# Taken from https://mathias-kettner.de/checkmk_multisite_login_dialog.html :
# Each users has a so called serial which is a simple number which is increased after each password change or locking of the user.
#
# Note this script currently does not hanlde incrementing the users serial.
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

  opts.on('-f', '--file <file>', 'Path to the omd sites auth.serials file') do |file|
    options[:file] = file;
  end

  ARGV.push('-h') if ARGV.empty?
end.parse!

serial_hash = Hash.new()

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

# tr is removing the '{' & '}'s in the string then parsing the string into a nested hash
user_file = File.open(options[:users])
user_hash = user_file.read.tr("{}", "").to_h()

# parses the current auth.serials into a hash
File.open(options[:file], "r").read.each_line do |line|
  key,value = line.split ':',2
  serial_hash[key] = value
end

# if serial file doesn't contain a managed users add them to the serial
# hash with a default value of 0
user_hash.to_a.each do |key,value|
  if !serial_hash.key?(key)
    serial_hash[key]='0'
  end
end

# write the updated auth.serials file
fileWrite = File.open(options[:file], "w")
serial_hash.sort.each do |key, value|
  fileWrite.puts key+':'+value
end
fileWrite.close
