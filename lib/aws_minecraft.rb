require 'thor'
require 'time'

module AWSMine
  class AWSMine
    def initialize
    end

    def color_shell
      Thor::Shell::Color.new
    end
  end
end
