#!/usr/bin/env ruby

# Todo: Basic AWS auth items. --> this needs to be dead simple
# Todo: Deploy a cfn stack via ruby
# Todo: Get ouputs from a previous stack --> pass to new stack.
# Todo: Check to see if a stack exists
# Todo: Read ini file to see about parent stacks and variables.
# Todo: Don't panic.

require 'aws-sdk'
require 'inifile'
require 'trollop'
require 'yaml'
require 'json'


def get_aws_creds(global_opts)
  if global_opts[:aws_env_key]
    my_credentials = Aws::SharedCredentials.new(profile_name: global_opts[:aws_env_key])
  else
    my_credentials = Aws::SharedCredentials.new(profile_name: 'default')
  end
  return my_credentials
end

def get_cfn(credentials, region)
  cfn = Aws::CloudFormation::Client.new(
                                       region: region,
                                       credentials: credentials
  )
  return cfn
end

def list(global_opts, cmd_opts)
  creds = get_aws_creds( global_opts )
  cmd_opts[:region] ? region = cmd_opts[:region] : region = 'us-east-1'
  cfn = get_cfn(creds, region)

  stacks = cfn.list_stacks(
      stack_status_filter: [:CREATE_IN_PROGRESS, :CREATE_FAILED, :CREATE_COMPLETE, :ROLLBACK_IN_PROGRESS, :ROLLBACK_FAILED, :ROLLBACK_COMPLETE, :DELETE_IN_PROGRESS, :DELETE_FAILED, :UPDATE_IN_PROGRESS, :UPDATE_COMPLETE_CLEANUP_IN_PROGRESS, :UPDATE_COMPLETE, :UPDATE_ROLLBACK_IN_PROGRESS, :UPDATE_ROLLBACK_FAILED, :UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS, :UPDATE_ROLLBACK_COMPLETE]
      #stack_status_filter: [:CREATE_IN_PROGRESS, :CREATE_FAILED, :CREATE_COMPLETE]
  )
  stacks[:stack_summaries].each do |stack|
    puts "Stack: #{stack[:stack_name]}"
    puts "\tcreation time: #{stack[:creation_time]}"
    puts "\tstack status: #{stack[:stack_status]}"
  end
end

def outputs(global_opts, cmd_opts)
  creds = get_aws_creds( global_opts )
  cmd_opts[:region] ? region = cmd_opts[:region] : region = 'us-east-1'
  cfn = get_cfn(creds, region)
  cfn_resource = Aws::CloudFormation::Resource.new(client: cfn)

  stack = cfn_resource.stack(cmd_opts[:stack])
  stack.outputs.each do |output|
    puts "Name #{output.output_key} and value = #{output.output_value}"
  end
end

def get_stack_outputs(creds, region, cfn_stack)

  cfn = get_cfn(creds, region)
  cfn_resource = Aws::CloudFormation::Resource.new(client: cfn)

  stack = cfn_resource.stack(cfn_stack)
  output_hash = Hash.new
  stack.outputs.each do |output|
    puts "Name #{output.output_key} and value = #{output.output_value}"
    output_hash[output.output_key] = output.output_value
  end
  return output_hash
end


# Simple function to read in the config to a hash
def read_config( config_file )
  return IniFile.load(config_file)
end

def get_parents(config, stackname)
  if config[stackname].has_key?('parents')
    parents = config[stackname]['parents'].split(',')
  end

  return parents
end

# Parse config to find all the inputs. This will read the global section.
# Todo: parse globals.
# todo: parse params
# todo: validate_actual params
def parse_params( environment, config , cfn_template, region, creds, stack)
  parameters = Array.new

  if cfn_template.has_key?('Parameters')
    cfn_template['Parameters'].each_key do |key|
      parameters.push(key)

    end
  end

    count = 0
    # config[environment].each_key do |key|
    parameters.each do |key|
      # config[environment].each_key do |key|
      if config[environment].has_key?(key)
        parameters[count] = Hash.new
        parameters[count][:parameter_key] = key
        parameters[count][:parameter_value] = config[environment][key]
        count = count +1
      elsif config['global'].has_key?(key)
        parameters[count] = Hash.new
        parameters[count][:parameter_key] = key
        parameters[count][:parameter_value] = config['global'][key]
        count = count +1
      end
    end
    return parameters
end

def parse_all_params( environment, config , cfn_template, region, creds, stackname)
  parameters = Hash.new

  if cfn_template.has_key?('Parameters')
    cfn_template['Parameters'].each_key do |key|
      parameters[key] = ''
    end
  end

  parents = get_parents(config, stackname)
  unless parents.nil?
    parents.each do |stack|
      puts "Gets stack output"
      cfn_outputs =  get_stack_outputs(creds, region, stack)
      parameters.each_key do |key|
        if cfn_outputs.has_key?(key)
          parameters[key] = cfn_outputs[key]
        end
      end

    end

  end

  # config[environment].each_key do |key|
  parameters.each_key do |key|
    # config[environment].each_key do |key|
    if config[environment].has_key?(key)
      parameters[key]= config[environment][key]
    elsif config['global'].has_key?(key)
      parameters[key]= config['global'][key]
    end
  end
  cfn_params = Array.new
  count = 0
  parameters.each do |key, value|
    cfn_params[count] = Hash.new
    cfn_params[count][:parameter_key] = key
    cfn_params[count][:parameter_value] = value.to_s
    count = count + 1
  end

  return cfn_params
end

def generate_stack_name(config, stackname)
  # puts "This will genenerate the stack name with some magic."
  return stackname
end

def create(global_opts, cmd_opts)
  creds = get_aws_creds( global_opts )
  config = read_config(global_opts[:config])
  cloudformation = File.read(cmd_opts[:cfn])
  cfn_hash = JSON.parse(cloudformation)
  cmd_opts[:region] ? region = cmd_opts[:region] : config['global'].has_key?('region') ? region = config['global']['region'] : region = 'us-east-1'
  cfn = get_cfn(creds, region)
  stack_name = generate_stack_name(config, cmd_opts[:stack])
  global_opts[:config] ? params = parse_all_params(cmd_opts[:environment], config, cfn_hash, region, creds, stack_name) : params = Array.new
  puts params
  # stack_name = cmd_opts[:stack]
  resp = cfn.create_stack(
      # required
      stack_name: stack_name, # passed from command line.
      template_body: cloudformation, # read this from file.
      parameters: params ,
      disable_rollback: true, # I like this.
      timeout_in_minutes: 30,  # should bump this up to 15
      #notification_arns: ["NotificationARN", '...'],
      capabilities: ["CAPABILITY_IAM"], # '...'],
      #on_failure: "DO_NOTHING", #"DO_NOTHING|ROLLBACK|DELETE",
      # stack_policy_body: "StackPolicyBody",
      # stack_policy_url: "StackPolicyURL",
      # tags: [
      #     {
      #         key: "TagKey",
      #         value: "TagValue",
      #     },
      # ],
  )
  puts "Create all the things."
end

if __FILE__ == $0
  SUB_COMMANDS = %w(create delete update list outputs)

  global_opts = Trollop::options do
    version "0.1.0"
    banner <<-EOS
cfnmason is a tool for building and deploying cloud formation stacks

Usage:
       cfnmason [options] <command> [command_options]
where [options] are:
    EOS
    # banner "magic file deleting and copying utility"
    opt :dry_run, "Don't actually do anything", :short => "-n"
    opt :aws_env_key, "Which environment to us if using aws shared creds", short: '-a', type: :string
    opt :verbose
    opt :config, "Environment configuration file", type: :string # todo: replace the stuff below with this
    opt :version
    stop_on SUB_COMMANDS
  end

  cmd = ARGV.shift # get the subcommand
  cmd_opts = case cmd
               when "create" # parse delete options
                 Trollop::options do
                   banner <<-EOS
cfnmason create will create new cloudformation stacks

Usage:
     cfnmason create -c environment_config -s stack_name
where [options] are:
                   EOS
                   opt :stack, "Stack to be created on AWS", required: true, type: :string
                   opt :region, "aws region to list stacks on", short: '-r', type: :string
                   opt :cfn, "Cloud Formation Template", type: :string
                   opt :environment, "dev, qa, stage, prod", type: :string, short: '-e'
                 end
               when "outputs" # handle listing the stacks
                 Trollop::options do
                   opt :region, "aws region to list stacks on", short: '-r', type: :string
                   opt :stack, "Stack to list outputs", short: '-s', required: true, type: :string
                 end
               when 'list' # handle listing the stacks
                 Trollop::options do
                   opt :region, "aws region to list stacks on", short: '-r', type: :string
                 end

               else
                 Trollop::die "unknown subcommand #{cmd.inspect}"
             end

  if cmd == 'list'
    list(global_opts,cmd_opts)
  elsif cmd == 'create'
    create(global_opts, cmd_opts)
  elsif cmd == 'outputs'
    outputs(global_opts, cmd_opts)
  end
  # puts "Global options: #{global_opts.inspect}"
  # puts "Subcommand: #{cmd.inspect}"
  # puts "Subcommand options: #{cmd_opts.inspect}"
  # puts "Remaining arguments: #{ARGV.inspect}"
end
