# Require pp must be before fakefs. Otherwise there is an error:'superclass mismatch for class File'
require 'pp'
require 'fakefs/spec_helpers'
require 'aws-sdk'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
end

shared_examples 'with aws minecraft' do
  before(:all) do
    # Loading metadata for AWS before FakeFS kicks in.
    RSpec::Mocks.with_temporary_scope do
      Aws::SharedCredentials.new
      Aws::EC2::Client.new
      Aws::EC2::Resource.new
    end
  end
  include FakeFS::SpecHelpers

  before :each do
    FakeFS.activate!
    FakeFS::FileSystem.clone(File.join(File.dirname(__FILE__), '../cfg'))
    FakeFS do
      # FileUtils.mkdir_p(File.join(__dir__, '../cfg'))
      File.open(File.join(__dir__, '../cfg/config.yml'), 'w') do |f|
        f.puts('loglevel: ERROR')
        f.puts('upload_path: /drop')
      end
      File.open(File.join(__dir__, '../cfg/user_data.sh'), 'w') do |f|
        f.puts <<-FILE
          !#/bin/bash
        FILE
      end
      File.open(File.join(__dir__, '../cfg/minecraft.key'), 'w') do |f|
        f.puts <<-FILE
          mykey
        FILE
      end
    end
  end
end
