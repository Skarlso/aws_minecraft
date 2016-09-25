require 'yaml'

module AWSMine
  # MineConfig is a configuration loader
  class MineConfig
    attr_reader :loglevel
    def initialize
      config = YAML.load_file(File.join(__dir__, '../../cfg/config.yml'))
      @loglevel = config['loglevel']
    end
  end
end
