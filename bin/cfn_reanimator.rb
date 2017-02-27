#!/usr/bin/env ruby

require 'aws-sdk'
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

main do

  if options[:verbose]
    logger.level = Logger::DEBUG
  else
    logger.level = Logger::WARN
  end

  puts " I need to add a bunch of code."
  # TODO: Whole list of things. Lets walk through them.
  # Read config file.
  #   -- Do a whole bunch of magic with that.
  #   --  Create prereq cfn stacks
  #   -- add an input variable file


end

version     '0.0.2'
description 'Convert SpecFile and blocks into a Cloudformation file to use with AWS'
#arg         :some_arg, :required

on("-v", "--verbose","Verbose Messaging")

go!
