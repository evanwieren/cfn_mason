#!/usr/bin/env ruby

require 'yaml'
require 'json'


file = File.read(ARGV[0])

output_dir = File

data_hash = JSON.parse(file)
#yaml_data = data_hash.to_yaml

#puts yaml_data

#config_options['source_and_target_cols_map'][0].each {|k,v| key = k,value = v}

# yaml_data['Parameters'][0].each do |k,v|
#   key = k
#   value = y
#   puts "#{key} and value is : #{value}"
# end

#puts yaml_data.inspect

# data_hash['Parameters'].each do |key|
#   puts "Key is = #{key}"
#   puts key.to_yaml
# end

cloudformation = Hash.new
cloudformation[:params] = data_hash['Parameters']
cloudformation[:mappings] = data_hash['Mappings']
cloudformation[:resources] = data_hash['Resources']
cloudformation[:outputs] = data_hash['Outputs']

# puts params.to_yaml
# puts "=============================="
# puts "=============================="
# puts "=============================="
# puts "=============================="

# This works to create a bunch of small yaml files.
# Can use this to break down/out a cloudformation stack.
cloudformation.each_key do |cf_key|
  my_hash = Hash.new
  count = 0
  cloudformation[cf_key].each_key do |key|
    my_hash[count] = Hash.new
    my_hash[count][key] = cloudformation[cf_key][key]
    puts my_hash[count].to_yaml
    # count = count + 1
    puts "=============================="
  end

end
