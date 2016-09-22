#!/usr/bin/env ruby

require 'thor'
require 'aws_minecraft'

# Providing a binary for AWSMine.
class AWSMineCli < Thor
  def initialize(*args)
    super
    @aws_mine = AWSMine::AWSMine.new
  end

  desc 'start-instance', 'Starts an EC2 instance.'
  def start_instance
    @aws_mine.start_instance
  end

  def stop_instance
  end

  # Handle minecraft server version here.
  desc 'start-server', 'Starts a minecraft server.'
  def start_server
  end

  def stop_server
  end

  def attach_to_server
  end

  def upload_world
  end
end

AWSMineCli.start
