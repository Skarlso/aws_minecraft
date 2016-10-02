require 'aws_minecraft/aws_helper'
require 'fakefs/spec_helpers'
require 'spec_helper'
require 'aws-sdk'

describe AWSMine::AWSHelper do
  include_context 'with aws minecraft'
  let(:ec2_client) { instance_double(Aws::EC2::Client) }
  let(:ec2_resource) { instance_double(Aws::EC2::Resource) }

  subject do |s|
    s = described_class.new
    s.ec2_client = ec2_client
    s.ec2_resource = ec2_resource
    s
  end

  describe '#initialize' do
    it 'should be an instance of MineConfig' do
      expect(subject).instance_of? AWSMine::AWSHelper
    end
  end

  describe '#create_ec2' do
    let(:sg) { instance_double(Aws::EC2::SecurityGroup) }
    let(:ec2) { instance_double(Aws::EC2::Instance) }
    let(:ec2s) { instance_double(Aws::EC2::Instances) }
    let(:client) { instance_double(Aws::Client) }
    it 'should create an ec2 instance' do
      expect(ec2_client).to receive(:describe_key_pairs).with(key_names: ['minecraft_keys'])
      expect(ec2_resource).to receive(:create_security_group).with(dry_run: false,
                                                                   group_name: 'mine_group',
                                                                   description: 'minecraft_group')
        .and_return(sg)
      expect(sg).to receive(:authorize_ingress)
      expect(sg).to receive(:id).and_return('sg-1')
      expect(ec2_resource).to receive(:create_instances)
        .with(dry_run: false,
              image_id: 'ami-ea26ce85',
              key_name: 'minecraft_keys',
              min_count: 1,
              max_count: 1,
              instance_type: 't2.nano',
              monitoring: { enabled: true },
              security_group_ids: ['sg-1'],
              user_data: "ICAgICAgICAgICEjL2Jpbi9iYXNo\n")
        .and_return([ec2])
      expect(ec2_resource).to receive(:client).and_return(client)
      expect(ec2).to receive(:id).exactly(4).times.and_return('ec2-id')
      expect(client).to receive(:wait_until).with(:instance_status_ok, instance_ids: ['ec2-id'])
      expect(ec2_resource).to receive(:instances).with(instance_ids: ['ec2-id']).and_return([ec2])
      expect(ec2).to receive(:public_ip_address).twice.and_return('1.2.3.4')
      expect(subject.create_ec2).to eq(['1.2.3.4', 'ec2-id'])
    end
  end
end
