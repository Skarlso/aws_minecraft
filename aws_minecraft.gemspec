# -*- encoding: utf-8 -*-

require File.join(File.dirname(__FILE__), 'lib', 'aws_minecraft', 'version')

Gem::Specification.new do |s|
  s.name = 'aws_minecraft'
  s.version = AWSMine::AWSMine::VERSION
  s.required_rubygems_version =
    Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['Gergely Brautigam']
  s.summary = 'A minecraft server provisioner on an AWS EC2 instance.'
  s.description = 'Provisions an EC2. Uploads a world, and deploys it.'
  s.email = 'skarlso777@gmail.com'
  s.extra_rdoc_files = ['README.md']
  s.files = `git ls-files`.split("\n")
  s.files << './cfg/minecraft.key'
  s.homepage = 'https://github.com/Skarlso/aws_minecraft'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.rubygems_version = '2.6.6'
  s.test_files = `git ls-files`.split("\n").select { |f| f =~ /^specs/ }
  s.rubyforge_project = 'aws_minecraft'
  s.executables = `git ls-files -- bin/*`.split("\n")
                                         .map { |f| File.basename(f) }
  s.licenses    = ['MIT']

  # dependencies
  s.add_development_dependency 'code_stats'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'bundler'
end
