#!/usr/bin/ruby
require 'optparse'
require 'json'

#
# This script when provided a managed users hash and an omd
# sites contacts.mk file will manage each specified users:
# 	username,
# 	alias,
# 	contactgroups,
# 	disable_notifications,
# 	email,
# 	pager
#
# If a user is not managed but is present in the contacts.mk file
# (ie added via wato or were previously managed), that users information
# will not be modified
#
# A sites contacts.mk file is typically located at:
# ( /opt/omd/sites/<omdsite>/etc/check_mk/conf.d/wato/contacts.mk )
#
# Written By: Garrett Rowell
# Last Edit: 2-15-2016
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

# Read the contacts.mk file
file = String.new
fileOpen=File.open(options[:file])
# Convert into json format
fileOpen.each_with_index do |line, index|
  # remove header
  if index >= 4
    # replace ' with "
    line=line.gsub(/'/, '"')
    # if line contains u"username" replace with only "username"
    line=line.gsub(/\su"/, '"')
    # Convert disable_notifications boolean to string
    line=line.gsub(/:\sTrue/, ': "True"')
    line=line.gsub(/:\sFalse/, ': "False"')
    # Remove last line
    file = file + line unless fileOpen.eof?
  end
end
fileOpen.close
# Parse json into hash
data_hash = JSON.parse(file)

# If contacts.mk file doesn't reflect the information provided about managed users, change it
# to match
user_hash.to_a.each do |key, value|
  if !data_hash.has_key?(key)
    data_hash[key] = Hash.new()
  end
  if user_hash[key].has_key?('alias')
    data_hash[key]['alias'] = user_hash[key]['alias']
  else
    data_hash[key]['alias'] = key
  end
  if user_hash[key].has_key?('contactgroups')
    data_hash[key]['contactgroups'] = user_hash[key]['contactgroups']
  else
    data_hash[key]['contactgroups'] = []
  end
  if user_hash[key].has_key?('disable_notifications')
    data_hash[key]['disable_notifications'] = user_hash[key]['disable_notifications']
  else
    data_hash[key]['disable_notifications'] = 'False'
  end
  if user_hash[key].has_key?('email')
    data_hash[key]['email'] = user_hash[key]['email']
  else
    data_hash[key]['email'] = ''
  end
  if user_hash[key].has_key?('pager')
    data_hash[key]['pager'] = user_hash[key]['pager']
  else
    data_hash[key]['pager'] = ''
  end
end

fileWrite = File.open(options[:file], "w")

$stdout.sync = true
fileWrite.print "# Written by Multisite UserDB\n# encoding: utf-8\n\ncontacts.update(\n"
data_hash.sort.each_with_index do |(key, value), index|
  out1 = "'#{key}': {"
  if index == 0
    out1 = '{'+out1
  else
    out1 = ' '+out1
  end
  fileWrite.print out1
  data_hash[key].each_with_index do |(key1, value1), index1|
    oper = nil
    if value1 == 'True' or value1 == 'False' or value1.to_s =~ /\[.*\]/
      oper = ""
    else
      oper = "'"
    end
    if value1 =~ /\[.*\]/i
      value1 = value1.gsub(/\b\w+\b/) { |m| "'#{m}'" }
    end
    if index1 == 0
      if key1 == 'alias'
        out2 = "'#{key1}': u#{oper}#{value1}#{oper}"
      else
        out2 = "'#{key1}': #{oper}#{value1}#{oper}"
      end
      if index1 == (value.length-1)
        out2 = out2 + "},\n"
      else
        out2 = out2 + ",\n"
      end
    elsif index1 > 0 and index1 != (value.length-1)
      out2 = "#{' '*out1.size}'#{key1}': #{oper}#{value1}#{oper},\n"
    elsif index1 == (value.length-1) and index == (data_hash.length-1)
      out2 = "#{' '*out1.size}'#{key1}': #{oper}#{value1}#{oper}}}\n"
    elsif index1 == (value.length-1)
      out2 = "#{' '*out1.size}'#{key1}': #{oper}#{value1}#{oper}},\n"
    end
    fileWrite.print out2
  end
end
fileWrite.print ')'
fileWrite.close
