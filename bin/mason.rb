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


def get_aws_creds(global_opts)
  if global_opts[:aws_env_key]
    my_credentials = Aws::SharedCredentials.new(profile_name: global_opts[:aws_env_key])
  else
    my_credentials = Aws::SharedCredentials.new(profile_name: 'default')
  end
  return my_credentials
end

def list(global_opts, cmd_opts)
  creds = get_aws_creds( global_opts )
  cmd_opts[:region] ? region = cmd_opts[:region] : region = 'us-east-1'

  cfn = Aws::CloudFormation::Client.new(
                                      region: region,
                                      credentials: creds
  )

  stacks = cfn.list_stacks(
      stack_status_filter: [:CREATE_IN_PROGRESS, :CREATE_FAILED, :CREATE_COMPLETE, :ROLLBACK_IN_PROGRESS, :ROLLBACK_FAILED, :ROLLBACK_COMPLETE, :DELETE_IN_PROGRESS, :DELETE_FAILED, :UPDATE_IN_PROGRESS, :UPDATE_COMPLETE_CLEANUP_IN_PROGRESS, :UPDATE_COMPLETE, :UPDATE_ROLLBACK_IN_PROGRESS, :UPDATE_ROLLBACK_FAILED, :UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS, :UPDATE_ROLLBACK_COMPLETE]
      #stack_status_filter: [:CREATE_IN_PROGRESS, :CREATE_FAILED, :CREATE_COMPLETE]
  )
  stacks[:stack_summaries].each do |stack|
    puts "Stack: #{stack[:stack_name]}"
    puts "\tcreation time: #{stack[:creation_time]}"
    puts "\tstack status: #{stack[:stack_status]}"
    puts
  end




  exit(1)
end


if __FILE__ == $0
  SUB_COMMANDS = %w(create delete update list)

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
    opt :verbose, short: '-v'
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
                   opt :config, "Environment configuration file", required: true
                   opt :stack, "Stack to be created on AWS", required: true
                 end
               when "delete"  # needs to be done
                 Trollop::options do
                   opt :double, "Copy twice for safety's sake"
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
  end
  puts "Global options: #{global_opts.inspect}"
  puts "Subcommand: #{cmd.inspect}"
  puts "Subcommand options: #{cmd_opts.inspect}"
  puts "Remaining arguments: #{ARGV.inspect}"



end