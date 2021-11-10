require "climate_control"
require "webmock/rspec"
require "rspec"
require "timecop"
require "pry"
require "vcr"
require_relative "../lib/loader"

Dir.glob("./spec/support/*.rb").sort.each { |file| require file }

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
end

RSpec.configure do |config|
  config.include StubHelpers
end
