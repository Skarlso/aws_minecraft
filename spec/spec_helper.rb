require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
end
shared_examples 'with aws minecraft' do
  before :each do
    include FakeFS::SpecHelpers
    FakeFS.activate!
    FakeFS::FileSystem.clone(__dir__)
  end
end
