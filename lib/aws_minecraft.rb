require 'aws_minecraft/aws_helper'
require 'aws_minecraft/db_helper'
require 'aws_minecraft/upload_helper'
require 'aws_minecraft/mine_config'
require 'aws_minecraft/ssh_helper'
require 'logger'

module AWSMine
  # Main class for AWS Minecraft
  class AWSMine
    MINECRAFT_SESSION_NAME = 'minecraft'.freeze
    attr_accessor :aws_helper, :db_helper, :upload_helper, :ssh_helper

    def initialize
      @aws_helper = AWSHelper.new
      @db_helper = DBHelper.new
      @upload_helper = UploadHelper.new
      @ssh_helper = SSHHelper.new
      @logger = Logger.new($stdout)
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
      @logger.info('WARNING! Terminating an instance will result in dataloss. Make ' \
                   'sure everything is backed up. Do you want to continue? (Y/n):')
      answer = $stdin.gets.chomp
      return unless answer == 'Y'

      ip, id = @db_helper.instance_details
      @logger.info("Terminating instance #{ip} | #{id}.")
      @aws_helper.terminate_ec2(id)
      @db_helper.remove_instance
    end

    def start_server(name)
      @logger.info("Starting server: #{name}.")
      cmd = "cd /home/ec2-user/data && ../tmux-2.2/tmux new -d -s #{MINECRAFT_SESSION_NAME} " \
            "'echo eula=true > eula.txt && java -jar #{name} nogui'"
      @logger.info("Running command: '#{cmd}'")
      remote_exec(cmd)
      ip, = @db_helper.instance_details
      @logger.info("Server URL is: #{ip}:25565")
    end

    def stop_server
      @logger.info('Stopping server')
      ip, = @db_helper.instance_details
      @ssh_helper.stop_server(ip)
    end

    def attach_to_server
      @logger.info("Attaching to server: #{MINECRAFT_SESSION_NAME}.")
      ip, = @db_helper.instance_details
      @ssh_helper.attach_to_server(ip)
    end

    def init_db
      @logger.info 'Creating db.'
      @db_helper.init_db
      @logger.info 'Done.'
    end

    def upload_world
    end

    def upload_files
      ip, = @db_helper.instance_details
      @upload_helper.upload_files(ip)
    end

    def remote_exec(cmd)
      ip, = @db_helper.instance_details
      @ssh_helper.remote_exec(ip, cmd)
    end

    def ssh
      ip, = @db_helper.instance_details
      @ssh_helper.ssh(ip)
    end
  end
end
