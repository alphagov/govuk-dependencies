require 'webmock/rspec'
require 'rspec'
require 'timecop'
require_relative '../lib/loader'

WebMock.disable_net_connect!(allow_localhost: true)
