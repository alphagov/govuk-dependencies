require 'climate_control'
require 'webmock/rspec'
require 'rspec'
require 'timecop'
require 'pry'
require 'vcr'
require_relative '../lib/loader'

Bundler::Audit::Database.update!(quiet: true)
WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
end
