#!/usr/bin/env ruby

require 'yaml'
require 'json'
require 'methadone'
require 'fileutils'
require 'logger'

include Methadone::Main
include Methadone::CLILogging

logger = Logger.new(STDOUT)

#TODO: Need to add commandline ars and such. All to be done later.
# For now, just need it to work so can make it past the hump

# 1. Read in all the inputs from 1 directory to start with.
# 2. Match inputs to specfile.
# 3. Generate Yaml from new specfile.

main do

  file = File.read(options['input-cfn-file'])
  if options[:verbose]
    logger.level = Logger::DEBUG
  else
    logger.level = Logger::WARN
  end

  output_dir = options['output-dir']# + "/CFN_Blocks"

  resp = FileUtils.mkpath(output_dir)
  logger.debug("Using #{resp} as the Building Blocks Directory")

  cloudformation = JSON.parse(file)

  spec_hash = Hash.new
  spec_hash['AWSTemplateFormatVersion'] = [cloudformation['AWSTemplateFormatVersion']]
  spec_hash['Description'] = [cloudformation['Description']]

# This works to create a bunch of small yaml files.
# Can use this to break down/out a cloudformation stack.
  sections = ['Parameters', 'Mappings', 'Conditions', 'Resources', 'Outputs']
  sections.each do |cf_key|

    if cloudformation.has_key?(cf_key)

      data_dir = output_dir + "/#{cf_key.to_s}"
      spec_hash[cf_key] = Array.new

      # On a mac case is ignored. This can be dangerous
      unless Dir.exists? (data_dir)
        logger.debug("Creating directory: #{data_dir}")
        FileUtils.mkdir(data_dir)
        logger.debug("Created the following directory: #{data_dir}")
      end

      # Create the file and write the data to it.
      my_hash = Hash.new
      count = 0
      cloudformation[cf_key].each_key do |key|
        spec_hash[cf_key].push(key)
        logger.debug("Creating YAML for Section: #{cf_key.to_s} and Ojbect: #{key.to_s}")
        output_file = File.open("#{data_dir}/#{key.to_s}.yaml", 'w')
        my_hash[count] = Hash.new
        my_hash[count][key] = cloudformation[cf_key][key]
        output_file.write(my_hash[count].to_yaml)

        #puts my_hash[count].to_yaml
        # count = count + 1
        output_file.close
      end

    end
  end

  spec_file = File.open("#{output_dir}/#{options['name']}", 'w')

  spec_file.write(spec_hash.to_yaml)

end

version     '0.0.1'
description 'Break down Cloud Formation Template into Builing Blocks'
#arg         :some_arg, :required

on("-v", "--verbose","Verbose Messaging")
options['input-cfn-file'] = ''
on("-i INPUT_CFN_FILE","--input-cfn-file","Input Cloud Formation File")
on("-o OutputDir", "--output-dir OutputDir", "Output Directory for CFN blocks")
options['output-dir'] = Dir.pwd
on("-n SPEC_FILE", '--name SPEC_FILE', "Name to output the SpecFile to.")
options['name'] = "specfile.yaml"
#on("-i INPUT_CFN_FILE","--input-cfn-file","Input Cloud Formation File",/^\d+\.\d+\.\d+\.\d+$/)

go!
