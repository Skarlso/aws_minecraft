require 'aws_minecraft/aws_helper'

describe AWSMine::AWSHelper do
  describe '#initialize' do
    let(:awshelper) { AWSMine::AWSHelper.new }

    it 'should be an instance of MineConfig' do
      expect(awshelper).instance_of? AWSMine::AWSHelper
    end
  end
end
