require 'json'
require 'aws-sdk'
require 'logger'
require_relative 'mine_config'

module AWSMine
  # Main wrapper for AWS commands
  class AWSHelper
    def initialize
      # region: AWS_REGION
      # Credentials are loaded from environment properties
      credentials = Aws::SharedCredentials.new(profile_name: 'gergely')
      @ec2_client = Aws::EC2::Client.new(credentials: credentials)
      @ec2_resource = Aws::EC2::Resource.new(client: @ec2_client)
      @logger = Logger.new(STDOUT)
      @logger.level = Logger.const_get(MineConfig.new.loglevel)
    end

    def create_ec2(version)
      config = File.open(File.join(__dir__, '../../cfg/ec2_conf.json'),
                         'rb', &:read).chop
      @logger.debug("Configuration loaded: #{config}.")
      ec2_config = JSON.parse(config)
      ec2_config = symbolize(ec2_config)
      @logger.debug("Configuration symbolized: #{ec2_config}.")
      import_keypair
      @logger.debug('Keys imported.')
      instance = @ec2_resource.create_instances(ec2_config)[0]
      @ec2_resource.client.wait_until(:instance_status_ok,
                                      instance_ids: [instance.id])
      instance.create_tags(tags: [{ key: 'Name', value: 'MinecraftServer' },
                                  { key: 'Version', value: version }])
      @logger.debug('Instance started with ip | id: ' \
                    "#{instance.public_ip_address} | #{instance.id}")
      [instance.public_ip_address, instance.id]
    end

    def terminate_ec2
    end

    def stop_ec2
    end

    def state(id)
      resp = @ec2_client.describe_instances(dry_run: true,
                                            instance_ids: id,
                                            max_result: 1)
      @logger.debug("Response from describe_instances: #{resp}.")
      resp.reservations[0].instances[0].state.name
    end

    def remote_exec(host, cmd)
      @logger.debug("Executing '#{cmd}' on '#{host}'")
      # This should work if ssh key is loaded and AgentFrowarding is set to yes.
      Net::SSH.start(host, 'ec2-user') do |ssh|
        output = ssh.exec!(cmd)
        @logger.info output
      end
    end

    private

    def symbolize(obj)
      case obj
      when Hash
        return obj.inject({}) do |memo, (k, v)|
          memo.tap { |m| m[k.to_sym] = symbolize(v) }
        end
      when Array
        return obj.map { |memo| symbolize(memo) }
      else
        obj
      end
    end

    def import_keypair
      key = File.open(File.join(__dir__, '../../cfg/minecraft.key'),
                      'rb', &:read).chop
      resp = @ec2_client.import_key_pair(dry_run: true,
                                         key_name: 'minecraft_keys',
                                         public_key_material: key)
      p resp
    end
  end
end
