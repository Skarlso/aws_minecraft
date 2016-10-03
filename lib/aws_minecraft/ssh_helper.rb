require 'logger'
require_relative 'mine_config'

module AWSMine
  # Main wrapper for SSH commands
  class SSHHelper
    def initialize
      config = MineConfig.new
      @logger = Logger.new(STDOUT)
      @logger.level = Logger.const_get(config.loglevel)
    end

    def attach_to_server(ip)
      exec("ssh ec2-user@#{ip} -t 'cd /home/ec2-user && ./tmux-2.2/tmux attach -t #{AWSMine::MINECRAFT_SESSION_NAME}'")
    end

    def ssh(ip)
      exec("ssh ec2-user@#{ip}")
    end

    def remote_exec(host, cmd)
      @logger.debug("Executing '#{cmd}' on '#{host}'.")
      # This should work if ssh key is loaded and AgentFrowarding is set to yes.
      Net::SSH.start(host, 'ec2-user', config: true) do |ssh|
        output = ssh.exec!(cmd)
        @logger.info output
      end
    end

    def stop_server(host)
      Net::SSH.start(host, 'ec2-user', config: true) do |ssh|
        @logger.info('Opening channel to host.')
        channel = ssh.open_channel do |ch|
          @logger.info('Channel opened. Opening pty.')
          ch.request_pty do |c, success|
            unless success
              @logger.info('Failed to request channel.')
              raise
            end
            c.on_data do |_, data|
              puts "Received data: #{data}."
            end
            c.exec("cd /home/ec2-user && ./tmux-2.2/tmux attach -t #{AWSMine::MINECRAFT_SESSION_NAME}")
            @logger.info('Sending stop signal...')
            c.send_data("stop\n")
          end
        end
        channel.wait
      end
    end
  end
end
