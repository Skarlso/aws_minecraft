# Require pp must be before fakefs. Otherwise there is an error:'superclass mismatch for class File'
require 'pp'
require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
end

shared_examples 'with aws minecraft' do
  before :each do
    include FakeFS::SpecHelpers
    FakeFS.activate!
    FakeFS::FileSystem.clone(__dir__)
    FakeFS do
      FileUtils.mkdir_p(File.join(__dir__, '../cfg'))
      File.open(File.join(__dir__, '../cfg/config.yml'), 'w') do |f|
        f.puts('loglevel: INFO')
        f.puts('upload_path: /drop')
      end

      FileUtils.mkdir_p(File.join(__dir__, '../cfg'))
      File.open(File.join(__dir__, '../cfg/ec2_conf.json'), 'w') do |f|
        f.puts <<-FILE
          {
              "dry_run": false,
              "image_id": "ami-ea26ce85",
              "key_name": "minecraft_keys",
              "min_count": 1,
              "max_count": 1,
              "instance_type": "t2.nano",
              "monitoring": {
                  "enabled": true
              }
          }
        FILE
      end

      FileUtils.mkdir_p(File.join(__dir__, '../cfg'))
      File.open(File.join(__dir__, '../cfg/instances.sql'), 'w') do |f|
        f.puts <<-FILE
          create table instances (
                ip varchar(100),
                id varchar(100),
                PRIMARY KEY (id)
          );
        FILE
      end

      FileUtils.mkdir_p(File.join(__dir__, '../cfg'))
      File.open(File.join(__dir__, '../cfg/sg_config.json'), 'w') do |f|
        f.puts <<-FILE
          {
            "ip_permissions": [
              {
                "ip_protocol": "tcp",
                "from_port": 22,
                "to_port": 22,
                "ip_ranges": [{
                  "cidr_ip": "0.0.0.0/0"
                }]
              },
              {
                "ip_protocol": "tcp",
                "from_port": 25565,
                "to_port": 25565,
                "ip_ranges": [{
                  "cidr_ip": "0.0.0.0/0"
                }]
              }
            ]
          }
        FILE
      end

      FileUtils.mkdir_p(File.join(__dir__, '../cfg'))
      File.open(File.join(__dir__, '../cfg/user_data.sh'), 'w') do |f|
        f.puts <<-FILE
          !#/bin/bash
        FILE
      end

      FileUtils.mkdir_p(File.join(__dir__, '../cfg'))
      File.open(File.join(__dir__, '../cfg/minecraft.key'), 'w') do |f|
        f.puts <<-FILE
          somekey
        FILE
      end
    end
  end
end
