require 'yaml'

module AWSMine
  # MineConfig is a configuration loader
  class MineConfig
    attr_reader :loglevel, :profile, :upload_path
    def initialize
      config = YAML.load_file(File.join(__dir__, '../../cfg/config.yml'))
      @loglevel = config['loglevel']
      @profile = config['profile']
      @upload_path = config['upload_path']
    end
  end
end
