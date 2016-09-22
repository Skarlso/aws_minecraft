require 'thor'

module AWSMine
  class AWSMine
    def initialize
      @aws_helper = AWSMine::AWSHelper.new
    end

    def start_instance
      @aws_helper.create_ec2('1.9')
    end

    private

    def remote_exec
    end

    def color_shell
      Thor::Shell::Color.new
    end
  end
end
