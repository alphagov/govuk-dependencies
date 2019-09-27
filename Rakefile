require_relative 'dependapanda'
require 'bundler/audit/database'
require 'vcr'
require 'net/http'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
rescue LoadError
  p 'Could not load RSpec'
end

task :dependapanda do
  Dependapanda.new.send_simple_message
end

task :dependapanda_loud do
  Dependapanda.new.send_full_message
end

task :save_application_gemfiles do
  UseCases::Gemfiles::Save.new(
    fetch_gemfiles: UseCases::Gemfiles::Fetch.new(
      teams_use_case: UseCases::Teams::Fetch.new
    )
  ).execute
end

task :update_advisory_db do
  Bundler::Audit::Database.update!
end

desc "Recreate the vcr cassettes. For example `rake record_cassette[org:alphagov topic:govuk]`"
task :record_cassette, [:search_string] do |task, args|
  octokit = Octokit::Client.new(auto_paginate: true)

  puts "Deleting old cassette"
  File.delete("spec/fixtures/vcr_cassettes/repositories.yml") if File.exists?("spec/fixtures/vcr_cassettes/repositories.yml")

  VCR.configure do |config|
    config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
    config.hook_into :webmock
  end

  puts "Recording new cassette"
  VCR.use_cassette("repositories") do
    octokit.search_repos(args[:search_string])
  end
end
