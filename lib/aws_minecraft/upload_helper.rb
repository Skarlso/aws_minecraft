require_relative 'mine_config'
require 'net/scp'

module AWSMine
  # Main wrapper for Uploading files and the world
  class UploadHelper
    def initialize
      @config = MineConfig.new
      @logger = Logger.new(STDOUT)
      @logger.level = Logger.const_get(@config.loglevel)
    end

    def upload_files(ip)
      Net::SCP.start(ip, 'ec2-user') do |scp|
        scp.upload!(@config.upload_path,
                    '/home/ec2-user/data',
                    recursive: true) do |_, name, sent, total|
          @logger.info("#{name}: #{sent}/#{total}")
        end
      end
    end
  end
end
