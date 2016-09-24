require 'thor'
require 'aws_minecraft/aws_helper'
require 'aws_minecraft/db_helper'

module AWSMine
  class AWSMine
    def initialize
      @aws_helper = AWSHelper.new
      @db_helper = DBHelper.new
    end

    def start_instance
      @aws_helper.create_ec2('1.9')
    end

    def init_db
      @db_helper.init_db
    end

    private

    def remote_exec
    end

    def color_shell
      Thor::Shell::Color.new
    end
  end
end
