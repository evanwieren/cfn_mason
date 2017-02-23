#!/usr/bin/env ruby

require 'yaml'
require 'json'
require 'FileUtils'

file = File.read(ARGV[0])
cloudformation = JSON.parse(file)

cloudformation.each do |key|
  puts "#{key["ParameterKey"]} = #{key["ParameterValue"]}"
end

#!/usr/bin/env ruby

require 'yaml'
require 'erb'

config = YAML.load_file("MyTimeDev.specfile.yaml")

sub = Hash.new
config['Templates'].each do |items|
  sub["component_name"] = items.keys[0]
  # Add the resources to the Resources section of the config.
  config['Resources'].push(items.keys[0])
  items[items.keys[0]].each do |item|
    key, value = item.first
    sub[key] = value
  end

  erb = ERB.new(File.open("#{__dir__}/../blocks/Templates/KronosBaseEc2.yaml.erb").read, 0, '>')
  puts erb.result(binding)
end
