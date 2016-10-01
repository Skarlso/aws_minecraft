require 'aws_minecraft/mine_config'
require 'fakefs/spec_helpers'
require 'spec_helper'

describe AWSMine::MineConfig do
  describe '#initialize', fakefs: true do
    before :each do
      FakeFS do
        FileUtils.mkdir_p(File.join(__dir__, '../cfg'))
        File.open(File.join(__dir__, '../cfg/config.yml'), 'w') do |f|
          f.puts('loglevel: INFO')
          f.puts('upload_path: /drop')
        end
      end
    end

    let(:mineconfig) { AWSMine::MineConfig.new }
    it 'should be an instance of MineConfig' do
      expect(mineconfig).instance_of? AWSMine::MineConfig
    end

    it 'correctly setup variables which are loaded from the config file' do
      expect(mineconfig.loglevel).to eq('INFO')
      expect(mineconfig.upload_path).to eq('/drop')
    end
  end
end
