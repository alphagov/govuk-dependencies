require 'webmock/rspec'
require 'rspec'
require_relative '../lib/loader'

WebMock.disable_net_connect!(allow_localhost: true)
