#!/usr/bin/env ruby

require 'aws-sdk'
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

  puts " I need to add a bunch of code."

end

version     '0.0.2'
description 'Convert SpecFile and blocks into a Cloudformation file to use with AWS'
#arg         :some_arg, :required

on("-v", "--verbose","Verbose Messaging")

go!