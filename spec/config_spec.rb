require 'aws_minecraft/mine_config'
require 'fakefs/spec_helpers'
require 'spec_helper'

describe AWSMine::MineConfig do
  include_context 'with aws minecraft'
  describe '#initialize', fakefs: true do
    let(:mineconfig) { AWSMine::MineConfig.new }
    it 'should be an instance of MineConfig' do
      expect(mineconfig).instance_of? AWSMine::MineConfig
    end

    it 'correctly setup variables which are loaded from the config file' do
      expect(mineconfig.loglevel).to eq('ERROR')
      expect(mineconfig.upload_path).to eq('/drop')
    end
  end
end
