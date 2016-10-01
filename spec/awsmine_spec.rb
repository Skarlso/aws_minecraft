require 'aws_minecraft'
require 'fakefs/spec_helpers'
require 'spec_helper'

describe AWSMine::AWSMine, fakefs: true do
  include_context 'with aws minecraft'
  let(:db) { instance_double(AWSMine::DBHelper) }
  let(:aws) { instance_double(AWSMine::AWSHelper) }
  let(:ssh) { instance_double(AWSMine::SSHHelper) }
  let(:upload) { instance_double(AWSMine::UploadHelper) }
  subject do |s|
    s = described_class.new
    s.aws_helper = aws
    s.db_helper = db
    s.upload_helper = upload
    s.ssh_helper = ssh
    s
  end

  describe '#create_instance' do
    context 'stubbed helpers' do
      it 'should create an instance if it does not exists' do
        expect(db).to receive(:instance_exists?).and_return(false)
        expect(aws).to receive(:create_ec2).and_return(['1.2.3.4', 'i-asdf'])
        expect(db).to receive(:store_instance).with('1.2.3.4', 'i-asdf')
        subject.create_instance
      end
      it 'should return status and ip of instance if it already exists' do
        expect(db).to receive(:instance_exists?).and_return(true)
        expect(db).to receive(:instance_details).and_return(['1.2.3.4', 'i-asdf'])
        expect(aws).to receive(:state).and_return('running')
        subject.create_instance
      end
    end
  end
end
