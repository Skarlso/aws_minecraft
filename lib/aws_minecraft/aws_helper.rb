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
      config = File.read(File.join(__dir__, '../cfg/ec2_conf.json'),
                         rb, &:read).chop
      instance = @ec2_resource.create_instance(JSON.parse(config).to_hash)
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
  end
end
