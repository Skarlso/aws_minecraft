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

  describe '#start_instance' do
    it 'should start an instance if it exists' do
      expect(db).to receive(:instance_exists?).and_return(true)
      expect(db).to receive(:instance_details).and_return(['1.2.3.4', 'i-asdf'])
      expect(aws).to receive(:start_ec2).with('i-asdf').and_return('2.3.4.5')
      expect(db).to receive(:update_instance).with('2.3.4.5', 'i-asdf')
      subject.start_instance
    end
    it 'should return if instance does not exist' do
      expect(db).to receive(:instance_exists?).and_return(false)
      subject.start_instance
    end
  end

  describe '#stop_instance' do
    it 'should stop an instance if it exists' do
      expect(db).to receive(:instance_exists?).and_return(true)
      expect(db).to receive(:instance_details).and_return(['1.2.3.4', 'i-asdf'])
      expect(aws).to receive(:stop_ec2).with('i-asdf').and_return('2.3.4.5')
      subject.stop_instance
    end
    it 'should return if instance does not exist' do
      expect(db).to receive(:instance_exists?).and_return(false)
      subject.stop_instance
    end
  end

  describe '#terminate_instance' do
    it 'should terminate an instance if it exists and delete it from the db' do
      expect(db).to receive(:instance_exists?).and_return(true)
      allow($stdin).to receive(:gets) { 'y' }
      expect(db).to receive(:instance_details).and_return(['1.2.3.4', 'i-asdf'])
      expect(aws).to receive(:terminate_ec2).with('i-asdf')
      expect(db).to receive(:remove_instance)
      subject.terminate_instance
    end
    it 'should return if user chooses to not to terminate the instance' do
      expect(db).to receive(:instance_exists?).and_return(true)
      allow($stdin).to receive(:gets) { 'n' }
      subject.terminate_instance
    end
    it 'should return if there are no instances' do
      expect(db).to receive(:instance_exists?).and_return(false)
      subject.terminate_instance
    end
  end

  describe '#start_server' do
    it 'should start a server' do
      name = 'dunny'
      cmd = "cd /home/ec2-user && ./tmux-2.2/tmux new -d -s #{AWSMine::AWSMine::MINECRAFT_SESSION_NAME} " \
            "'echo eula=true > eula.txt && java -jar data/#{name} nogui'"
      expect(subject).to receive(:remote_exec).with(cmd)
      expect(db).to receive(:instance_details).and_return(['1.2.3.4', 'i-asdf'])
      subject.start_server(name)
    end
  end

  describe '#attach_to_server' do
    it 'should attach to a running server' do
      expect(db).to receive(:instance_details).and_return(['1.2.3.4', 'i-asdf'])
      expect(ssh).to receive(:attach_to_server).with('1.2.3.4')
      subject.attach_to_server
    end

    # TODO: There are a lot more things to cover here. Like, ssh expection.
    # Or if the db doesn't exists. Or the server is not running.
  end

  describe '#init_db' do
    it 'should initialize the db' do
      expect(db).to receive(:init_db)
      subject.init_db
    end
  end

  describe '#upload_files' do
    it 'should upload files from the specified location in the config.yml file' do
      expect(db).to receive(:instance_details).and_return(['1.2.3.4', 'i-asdf'])
      expect(upload).to receive(:upload_files).with('1.2.3.4')
      subject.upload_files
    end
  end

  describe '#remote_exec' do
    it 'should be able to exectue cmd on an instance' do
      expect(db).to receive(:instance_details).and_return(['1.2.3.4', 'i-asdf'])
      expect(ssh).to receive(:remote_exec).with('1.2.3.4', 'test_cmd')
      subject.remote_exec('test_cmd')
    end
  end

  describe '#ssh' do
    it 'should be able to ssh into a running instance' do
      expect(db).to receive(:instance_details).and_return(['1.2.3.4', 'i-asdf'])
      expect(ssh).to receive(:ssh).with('1.2.3.4')
      subject.ssh
    end
  end
end
