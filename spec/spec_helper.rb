$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'reading_log_extractor'

require 'webmock'
require 'vcr'

module Tests
  def self.fixtures
    specs_root.join('fixtures')
  end

  def self.fixtures_file(file)
    fixtures.join(file).to_s
  end

  def self.specs_root
    project_root.join('spec')
  end

  def self.project_root
    Pathname.new(Dir.pwd)
  end

  def self.support(filename)
    specs_root.join('support').join(filename).to_s
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
end

def disable_vcr
  WebMock.allow_net_connect!
  VCR.turn_off!
  yield
  VCR.turn_on!
  WebMock.disable_net_connect!
end
