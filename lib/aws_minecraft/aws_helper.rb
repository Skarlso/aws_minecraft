require 'json'
require 'aws-sdk'

module AWSMine
  # Main wrapper for AWS commands
  class AWSHelper
    def initialize
      # region: AWS_REGION
      # Credentials are loaded from environment properties
      credentials = Aws::SharedCredentials.new(profile_name: 'gergely')
      @ec2_client = Aws::EC2::Client.new(credentials: credentials)
      @ec2_resource = Aws::EC2::Resource.new(client: @ec2_client)
    end

    def create_ec2(version)
      config = File.open(File.join(__dir__,
                                   '../../cfg/ec2_conf.json'),
                         'rb', &:read).chop
      ec2_config = JSON.parse(config)
      ec2_config = symbolize(ec2_config)
      import_keypair
      instance = @ec2_resource.create_instances(ec2_config)
      @ec2_resource.client.wait_until(:instance_status_ok,
                                      instance_ids: [instance[0].id])
      instance.create_tags(tags: [{ key: 'Name', value: 'MinecraftServer' },
                                  { key: 'Version', value: version }])
      puts instance.id
      puts instance.public_ip_address
    end

    def terminate_ec2
    end

    def instance_ip(tag)
    end

    def instance_arn
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
      key = File.open(File.join(__dir__,
                                '../../cfg/gbrautigam.key'),
                      'rb', &:read).chop
      resp = @ec2_client.import_key_pair(dry_run: true, key_name: 'minecraft_keys',
                                         public_key_material: key)
      p resp
    end

    def generate_keypair(name)
    end
  end
end
