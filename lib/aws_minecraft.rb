require 'aws_minecraft/aws_helper'
require 'aws_minecraft/db_helper'
require 'aws_minecraft/mine_config'
require 'net/ssh'
require 'logger'

module AWSMine
  # Main class for AWS Minecraft
  class AWSMine
    def initialize
      @aws_helper = AWSHelper.new
      @db_helper = DBHelper.new
      @logger = Logger.new(STDOUT)
      @logger.level = Logger.const_get(MineConfig.new.loglevel)
    end

    def create_instance
      if @db_helper.instance_exists?
        ip, id = @db_helper.instance_details
        @logger.info 'Instance already exists.'
        state = @aws_helper.state(id)
        @logger.info "State is: #{state}"
        @logger.info "Public ip | id: #{ip} | #{id}"
        return
      end
      ip, id = @aws_helper.create_ec2
      @db_helper.store_instance(ip, id)
    end

    def start_instance
      unless @db_helper.instance_exists?
        @logger.info 'No instances found. Nothing to do.'
        return
      end
      ip, id = @db_helper.instance_details
      @logger.info("Starting instance #{ip} | #{id}.")
      new_ip = @aws_helper.start_ec2(id)
      @db_helper.update_instance(new_ip, id)
    end

    def stop_instance
      unless @db_helper.instance_exists?
        @logger.info 'No running instances found. Nothing to do.'
        return
      end
      ip, id = @db_helper.instance_details
      @logger.info("Stopping instance #{ip} | #{id}.")
      @aws_helper.stop_ec2(id)
    end

    def terminate_instance
      unless @db_helper.instance_exists?
        @logger.info 'No running instances found. Nothing to do.'
        return
      end
      ip, id = @db_helper.instance_details
      @logger.info("Terminating instance #{ip} | #{id}.")
      @aws_helper.terminate_ec2(id)
      @db_helper.remove_instance
    end

    def init_db
      @logger.info 'Creating db.'
      @db_helper.init_db
      @logger.info 'Done.'
    end

    def remote_exec(cmd)
      ip, = @db_helper.instance_details
      @logger.info("SSH-ing into: #{ip}.")
      @aws_helper.remote_exec(ip, cmd)
    end

    def ssh
      ip, = @db_helper.instance_details
      exec("ssh ec2-user@#{ip}")
    end
  end
end
