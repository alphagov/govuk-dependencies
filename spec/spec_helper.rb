require 'webmock/rspec'
require 'rspec'
require 'timecop'
require 'pry'
require_relative '../lib/loader'

Bundler::Audit::Database.update!(quiet: true)
WebMock.disable_net_connect!(allow_localhost: true)
