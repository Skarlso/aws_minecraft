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
      if @db_helper.instance_exists?
        ip, id = @db.instance_details
        puts 'Instance already exists.'
        state = @aws_helper.state(id)
        puts "State is: #{state}"
        puts "Public ip; id: #{ip} | #{id}"
        raise
      end
      ip, id = @aws_helper.create_ec2('1.9')
      @db_helper.store_instance(ip, id)
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
