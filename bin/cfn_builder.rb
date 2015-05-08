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

  specfile = YAML::load(File.open(options['input-specfile']))
  logger.info("Read in the specfile from #{options['input-specfile']}")
  puts specfile['Parameters']
  puts specfile['Parameters'].class

end

def parse_block_directory

version     '0.0.2'
description 'Break down Cloud Formation Template into Builing Blocks'
#arg         :some_arg, :required

on("-v", "--verbose","Verbose Messaging")
on("-i INPUT_SPEC_FILE","--input-specfile INPUT_SPEC_FILE","Input Cloud Formation SpecFile")
on("-o OUTPUT_FILE", "--output-file OUTPUT_FILE", "Output file for Cloud Formation Template")
options['output-file'] = Dir.pwd + "/cloudformation.template"
on("-b BLOCKS_DIRECTORY", "--blocks-dir BLOCKS_DIRECTORY", "Directory containing building blocks for CFN")
options['name'] = "specfile.yaml"
#on("-i INPUT_CFN_FILE","--input-cfn-file","Input Cloud Formation File",/^\d+\.\d+\.\d+\.\d+$/)

go!