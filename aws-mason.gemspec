Gem::Specification.new do |s|
  s.name        = 'aws-mason'
  s.version     = '0.0.0'
  s.date        = '2015-12-11'
  s.summary     = "A tool for simplifying working on AWS Cloudformation Stacks."
  s.description = "aws-mason is a tool that will allow you to create easily usable stacks within AWS. It breaks stacks into
easily digested pieces that can then be reused to build stacks. Stacks can also inherit from other stacks allowing CloudFormation
to be the record of source."
  s.authors     = ["Eric VanWieren"]
  s.email       = 'doiwanttoaddmyemail@email.com'
  all_files     = `git ls-files -z`.split("\x0")
  #s.executables << 'aws-mason'
  s.executables   = all_files.grep(%r{^bin/aws}) { |f| File.basename(f) }
  s.files       = ["lib/aws-mason.rb", 'lib/aws-mason/translator.rb']
  s.homepage    =
      'http://rubygems.org/gems/aws-mason'
  s.license       = 'MIT'
end