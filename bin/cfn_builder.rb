#!/usr/bin/env ruby

require 'yaml'
require 'json'
require 'methadone'
require 'FileUtils'
require 'logger'

include Methadone::Main
include Methadone::CLILogging

logger = Logger.new(STDOUT)

#TODO: Need to add commandline ars and such. All to be done later.
# For now, just need it to work so can make it past the hump

main do

  if options[:verbose]
    logger.level = Logger::DEBUG
  else
    logger.level = Logger::WARN
  end

  # Create a hash to hold all of the data as we build the CFN
  cfn = Hash.new
  output_cfn = Hash.new

  specfile = YAML::load(File.open(options['input-specfile']))
  logger.info("Read in the specfile from #{options['input-specfile']}")


  ['AWSTemplateFormatVersion', 'Description'].each do |meta_data|
    unless specfile[meta_data].length == 1
      puts 'Houston we have a problem'
      exit(1)
    end
    cfn[meta_data] = specfile[meta_data][0]
  end

  ['Parameters', 'Mappings', 'Conditions', 'Resources', 'Outputs'].each do |section|

    parse_cfn_blocks(options['blocks-dir'] + "/#{section}", section, specfile, cfn)

  end

  results = JSON.dump(cfn)

  if options['output-file']
    template_file = File.open(options['output-file'], 'w')

    template_file.write(JSON.pretty_generate(JSON.parse(results)))
  else
    puts JSON.pretty_generate(JSON.parse(results))
  end

end

# Pre: Directory full of 'yml' or 'yaml' files
# Read and add to given hash
def parse_cfn_blocks(directory, section, spec_file, cfn_hash)
  if Dir.exists?(directory)
    cfn_hash[section] = Hash.new
    spec_file[section].each do |param|
    # Dir.glob(directory +'/*.yaml') do |yaml_file|
      # do work on files ending in .rb in the desired directory
      item = YAML::load(File.open(directory + "/#{param}.yaml"))
      item.each_key do |key|
        cfn_hash[section][key] = Hash.new
        cfn_hash[section][key] = item[key]
      end
    end
  end
end

version     '0.0.2'
description 'Convert SpecFile and blocks into a Cloudformation file to use with AWS'
#arg         :some_arg, :required

on("-v", "--verbose","Verbose Messaging")
on("-i INPUT_SPEC_FILE","--input-specfile INPUT_SPEC_FILE","Input Cloud Formation SpecFile")
on("-o OUTPUT_FILE", "--output-file OUTPUT_FILE", "Output file for Cloud Formation Template")
#options['output-file'] = Dir.pwd + "/cloudformation.template"
on("-b BLOCKS_DIRECTORY", "--blocks-dir BLOCKS_DIRECTORY", "Directory containing building blocks for CFN")
# options['name'] = "specfile.yaml"
#on("-i INPUT_CFN_FILE","--input-cfn-file","Input Cloud Formation File",/^\d+\.\d+\.\d+\.\d+$/)

go!