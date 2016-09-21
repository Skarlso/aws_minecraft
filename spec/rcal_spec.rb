require 'aws_minecraft'

describe AWSMine::AWSMine do
  describe '#initialize' do
    let(:awsmine) { AWSMine::AWSMine.new }

    it 'should be an instance of AWSMine' do
      expect(awsmine).instance_of? AWSMine::AWSMine
    end
  end
end
