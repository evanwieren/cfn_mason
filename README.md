This is a series of utilities to manage Cloud Formation Templates.

The project has some core ideas:

* We are not writing a DSL to wrap Cloud Formation
* Provide a number of small utils that have specific tasks
* Integrate with AWS to allow CFN Stacks to be easily linked
* Parameters should be easy to configure outside of CFN template


CFN Utils Will follow this basic design.

- Environment SPECS Directory/File
    - This file will contain a list of the CFN stacks that are needed in order to build out an environment.
    - Can contain variables
    - Can specify different input params based on environment.
- Cloud Formation Spec
    - Simple yaml file indicating parameters needed
    - Contains Resources
    - Contains mappings
    - Outputs
- CFN Blocks (All in YAML)
    - Parameters
        - Each parameter will have its own building block
    - Mapptings
        - Allows for the mappings to be set by environment
    - Resources# Cfn::Mason

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/aws/mason`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cfnmason'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cfn-mason

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/aws-mason. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

