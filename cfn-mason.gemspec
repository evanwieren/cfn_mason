# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cfnmason/version'

Gem::Specification.new do |spec|
  spec.name          = "cfn-mason"
  spec.version       = CfnMason::VERSION
  spec.authors       = ["Eric VanWieren"]
  spec.email         = ["evanwieren@notgmail.com"]

  spec.summary       = %q{AWS Cloud Formation Utility Tool}
  spec.description   = %q{The goal is to provide a way to easily build CloudFormation templates using ruby. Then using aws-sdk gem, be able to push and follow status of CloudFormation templates.}
  spec.homepage      = "https://github.com/evanwieren/cfn_mason"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'
  spec.add_dependency 'inifile', '~> 3.0.0'
  spec.add_dependency 'aws-sdk', '~> 2.0.42'
  spec.add_dependency 'trollop'
  spec.add_dependency 'methadone'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
