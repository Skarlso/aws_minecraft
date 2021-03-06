require 'json'
require 'aws-sdk'
require 'logger'
require_relative 'mine_config'
require 'base64'

module AWSMine
  # Main wrapper for AWS commands
  class AWSHelper
    attr_accessor :ec2_client, :ec2_resource

    def initialize
      # region: AWS_REGION
      # Credentials are loaded from environment properties
      config = MineConfig.new
      credentials = Aws::SharedCredentials.new(profile_name: config.profile)
      @ec2_client = Aws::EC2::Client.new(credentials: credentials)
      @ec2_resource = Aws::EC2::Resource.new(client: @ec2_client)
      @logger = Logger.new($stdout)
      @logger.level = Logger.const_get(config.loglevel)
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def create_ec2
      @logger.info('Creating new EC2 instance.')
      config = File.read(File.join(__dir__, '../../cfg/ec2_conf.json'))
      @logger.debug("Configuration loaded: #{config}.")
      ec2_config = symbolize(JSON.parse(config))
      @logger.debug("Configuration symbolized: #{ec2_config}.")
      @logger.info('Importing keys.')
      import_keypair
      @logger.info('Creating security group.')
      sg_id = create_security_group
      ec2_config[:security_group_ids] = [sg_id]
      ec2_config[:user_data] = retrieve_user_data
      @logger.info('Creating instance.')
      instance = @ec2_resource.create_instances(ec2_config)[0]
      @logger.info('Instance created. Waiting for it to become available.')
      @ec2_resource.client.wait_until(:instance_status_ok,
                                      instance_ids: [instance.id]) do |w|
        w.before_wait do |_, _|
          @logger << '.'
        end
      end
      @logger.info("\n")
      @logger.info('Instance in running state.')
      pub_ip = @ec2_resource.instances(instance_ids: [instance.id]).first
      @logger.info('Instance started with ip | id: ' \
                    "#{pub_ip.public_ip_address} | #{instance.id}.")
      [pub_ip.public_ip_address, instance.id]
    end

    def terminate_ec2(id)
      @ec2_client.terminate_instances(dry_run: false, instance_ids: [id])
      @ec2_resource.client.wait_until(:instance_terminated,
                                      instance_ids: [id]) do |w|
        w.before_wait do |_, _|
          @logger << '.'
        end
      end
      @logger.info("\n")
      @logger.info('Instance terminated. Goodbye.')
    end

    def stop_ec2(id)
      @ec2_client.stop_instances(dry_run: false, instance_ids: [id])
      @ec2_resource.client.wait_until(:instance_stopped,
                                      instance_ids: [id]) do |w|
        w.before_wait do |_, _|
          @logger << '.'
        end
      end
      @logger.info("\n")
      @logger.info('Instance stopped. Goodbye.')
    end

    def start_ec2(id)
      @ec2_client.start_instances(dry_run: false, instance_ids: [id])
      @ec2_resource.client.wait_until(:instance_running,
                                      instance_ids: [id]) do |w|
        w.before_wait do |_, _|
          @logger << '.'
        end
      end
      pub_ip = @ec2_resource.instances(instance_ids: [id]).first
      @logger.info("Instance started. New ip is:#{pub_ip.public_ip_address}.")
      pub_ip.public_ip_address
    end

    def state(id)
      instance = @ec2_resource.instances(instance_ids: [id]).first
      @logger.debug("Response from describe_instances: #{instance}.")
      instance.state.name
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
      file = File.join(__dir__, '../../cfg/minecraft.key')
      raise 'key not found. make sure cfg/minecraft.key exists in the gem' unless File.exist?(file)

      key = Base64.decode64(File.read(file))
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
      @logger.debug("Response from import_key_pair: #{resp}.")
    end

    def create_security_group
      config = File.read(File.join(__dir__, '../../cfg/sg_config.json'))
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

    def retrieve_user_data
      user_data = File.read(File.join(__dir__, '../../cfg/user_data.sh'))
      Base64.encode64(user_data)
    end
  end
end
