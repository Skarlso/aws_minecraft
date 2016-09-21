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
  end

  def stop_instance
  end

  def start_server
  end

  def stop_server
  end

  def upload_world
  end

end

AWSMineCli.start
