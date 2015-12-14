#!/usr/bin/env ruby

require 'yaml'
require 'json'
require 'FileUtils'

file = File.read(ARGV[0])
cloudformation = JSON.parse(file)

cloudformation.each do |key|
  puts "#{key["ParameterKey"]} = #{key["ParameterValue"]}"
end
