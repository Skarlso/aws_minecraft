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

    def create_ec2
      @logger.info('Creating new EC2 instance.')
      config = File.open(File.join(__dir__, '../../cfg/ec2_conf.json'),
                         'rb', &:read).chop
      @logger.debug("Configuration loaded: #{config}.")
      ec2_config = symbolize(JSON.parse(config))
      @logger.debug("Configuration symbolized: #{ec2_config}.")
      import_keypair
      sg_id = create_security_group
      ec2_config[:security_group_ids] = [sg_id]
      @logger.debug('Keys imported.')
      instance = @ec2_resource.create_instances(ec2_config)[0]
      @ec2_resource.client.wait_until(:instance_status_ok,
                                      instance_ids: [instance.id])
      # instance.create_tags(tags: [{ key: 'Name', value: 'MinecraftServer' },
      #                             { key: 'Version', value: '1.9' }])
      pub_ip = @ec2_resource.instances(instance_ids: [instance.id]).first
      @logger.info('Instance started with ip | id: ' \
                    "#{pub_ip.public_ip_address} | #{instance.id}")
      [pub_ip.public_ip_address, instance.id]
    end

    def terminate_ec2(id)
      @ec2_client.terminate_instances(dry_run: false, instance_ids: [id])
    end

    def stop_ec2
    end

    def state(id)
      resp = @ec2_client.describe_instances(dry_run: false,
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
      begin
        @ec2_client.describe_key_pairs(key_names: ['minecraft_keys'])
        key_exists = true
      rescue Aws::EC2::Errors::InvalidKeyPairNotFound
        key_exists = false
      end
      return if key_exists
      resp = @ec2_client.import_key_pair(dry_run: false,
                                         key_name: 'minecraft_keys',
                                         public_key_material: key)
      @logger.debug("Response from import_key_pair: #{resp}")
    end

    def create_security_group
      config = File.open(File.join(__dir__, '../../cfg/sg_config.json'),
                         'rb', &:read).chop
      sg_config = symbolize(JSON.parse(config))
      begin
        sg = @ec2_resource.create_security_group(dry_run: false,
                                                 group_name: 'mine_group',
                                                 description: 'minecraft_group')
        sg.authorize_ingress(sg_config)
        sg.id
      rescue Aws::EC2::Errors::InvalidGroupDuplicate
        @logger.info('Security Group already exists. Returning id.')
        @ec2_resource.security_groups(group_names: ['mine_group']).first.id
      end
    end
  end
end
