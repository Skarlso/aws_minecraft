require 'yaml'

module AWSMine
  # MineConfig is a configuration loader
  class MineConfig
    attr_reader :loglevel, :profile, :upload_path

    def initialize
      config = YAML.load_file(File.join(__dir__, '../../cfg/config.yml'))
      @loglevel = config['loglevel']
      @profile = ENV.fetch('AWS_DEFAULT_PROFILE', 'default')
      # Upload path is used so files can sit anywhere.
      @upload_path = config['upload_path']
    end
  end
end
