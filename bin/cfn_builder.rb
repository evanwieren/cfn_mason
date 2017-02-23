#!/usr/bin/env ruby

require 'yaml'
require 'json'
require 'methadone'
require 'FileUtils'
require 'logger'
require 'erb'

include Methadone::Main
include Methadone::CLILogging

@logger = Logger.new(STDOUT)

#TODO: Need to add commandline ars and such. All to be done later.
# This needs better error handling. and better responses.
# I should pony up and get that done at some point.
# probably when I move it over to a gem.. but I will leave this code here so as not
# to break backward compatibility.

main do

  if options[:verbose]
    @logger.level = Logger::DEBUG
  else
    @logger.level = Logger::WARN
  end

  # Create a hash to hold all of the data as we build the CFN
  cfn = Hash.new
  output_cfn = Hash.new

  @logger.info("Reading in the specfile from #{options['input-specfile']}")
  specfile = YAML::load(File.open(options['input-specfile']))
  @logger.info("Read in the specfile from #{options['input-specfile']}")

  @logger.info("Checking to see that a description exists in the specfile")
  ['AWSTemplateFormatVersion', 'Description'].each do |meta_data|
    unless specfile[meta_data].length == 1
      puts 'You are missing either AWSTemplateFormatVersion or Description from your Specfile'
      exit(1)
    end
    cfn[meta_data] = specfile[meta_data][0]
  end

  # Resources may not exist at this point.
  # Create it in case it does not exist yet.
  unless specfile.has_key?('Resources')
    specfile['Resources'] = Array.new
  end

  # Process the Template Section of the Specfile if it exists. Or just skip it.
  @logger.info("Processing any templates that exist")
  if specfile.has_key?('Templates')
    generate_components_from_erb(specfile, options['blocks-dir'])
  end

  @logger.debug("Stepping through each section of specfile")
  ['Parameters', 'Mappings', 'Conditions', 'Resources', 'Outputs'].each do |section|
    @logger.debug("Processing the #{section} section")

    parse_cfn_blocks(options['blocks-dir'] + "/#{section}", section, specfile, cfn)

  end

  @logger.debug("Preparing to dump JSON to file")
  results = JSON.dump(cfn)

  if options['output-file']
    template_file = File.open(options['output-file'], 'w')

    template_file.write(JSON.pretty_generate(JSON.parse(results)))
  else
    puts JSON.pretty_generate(JSON.parse(results))
  end

end

# Pre array from Yaml file for erb templates to read
# Post, generates yaml files for use in building the cfn template.
def generate_components_from_erb(spec_file, blocks_dir)
  @logger.debug("Processing the Templates section")
  sub = Hash.new
  spec_file['Templates'].each do |items|
    @logger.debug("Processing the component: #{items.keys[0]}")
    sub["component_name"] = items.keys[0]
    # Add the resources to the Resources section of the config.
    spec_file['Resources'].push(items.keys[0])
    items[items.keys[0]].each do |item|
      key, value = item.first
      sub[key] = value
    end

    @logger.debug("Opening the erb file for use")
    erb = ERB.new(File.open("#{blocks_dir}/Templates/#{sub['Template']}.yaml.erb").read, 0, '>')
    @logger.debug("Opening the resource file for writing")
    File.open("#{blocks_dir}/Resources/#{items.keys[0]}.yaml", 'w') do |f|
      f.puts erb.result(binding)
    end
  end
end

# Pre: Directory full of 'yml' or 'yaml' files
# Read and add to given hash
def parse_cfn_blocks(directory, section, spec_file, cfn_hash)
  if Dir.exists?(directory) and spec_file.has_key?(section)
    cfn_hash[section] = Hash.new
    spec_file[section].each do |param|
    # Dir.glob(directory +'/*.yaml') do |yaml_file|
      # do work on files ending in .rb in the desired directory
      @logger.debug("Loading #{param}.yaml file to parse")
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
