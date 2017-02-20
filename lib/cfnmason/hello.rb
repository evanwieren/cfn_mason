require 'thor'

module CfnMason
  class Hn < Thor
    desc "bye NAME", "This will greet you"
    long_desc <<-HELLO_WORLD

  `by NAME` will print out a message to the person of your choosing.


  http://stackoverflow.com/a/12785204
    HELLO_WORLD
    option :upcase
    def bye( name )
      greeting = "Hello, #{name}"
      greeting.upcase! if options[:upcase]
      puts greeting
    end
  end

end
