require 'widow'
require 'vcr'
require 'rspec'

include Widow

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end

def load_fixture(fixture_name)
  File.read File.join(File.dirname(File.expand_path(__FILE__)), "fixtures", fixture_name)
end
