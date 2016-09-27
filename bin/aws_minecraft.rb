#!/usr/bin/env ruby

require 'thor'
require 'aws_minecraft'

# Providing a binary for AWSMine.
class AWSMineCli < Thor
  def initialize(*args)
    super
    @aws_mine = AWSMine::AWSMine.new
  end

  desc 'create-instance', 'Creates an EC2 instance.'
  def create_instance
    @aws_mine.create_instance
  end

  desc 'start-instance', 'Starts an EC2 instance.'
  def start_instance
    @aws_mine.start_instance
  end

  desc 'stop-instance', 'Stops an EC2 instance.'
  def stop_instance
    @aws_mine.stop_instance
  end

  desc 'terminate-instance', 'Terminates an EC2 instance.'
  def terminate_instance
    @aws_mine.terminate_instance
  end

  desc 'ssh', 'SSH into a running EC2 instance.'
  def ssh
    # @aws_mine.remote_exec('ls -l')
    @aws_mine.ssh
  end

  # Handle minecraft server version here.
  desc 'start-server NAME', 'Starts a minecraft server.'
  def start_server(name = 'minecraft_server.jar')
    @aws_mine.remote_exec('cd /home/ec2-user && echo eula=true > eula.txt ' \
                          "&& java -jar #{name}")
  end

  desc 'stop-server', 'Stops a minecraft server.'
  def stop_server
  end

  desc 'attach-to-server', 'Attach to a minecraft server.'
  def attach_to_server
  end

  desc 'upload-world', 'Upload world.'
  def upload_world
  end

  desc 'upload-files', 'Uploads everything from drop, not just the world.'
  def upload_files
    @aws_mine.upload_files
  end

  desc 'init-db', 'Initialize the databse.'
  def init_db
    @aws_mine.init_db
  end
end

AWSMineCli.start
