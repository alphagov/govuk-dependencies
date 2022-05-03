require_relative "dependapanda"
require_relative "lib/gateways/repositories"
require_relative "lib/gateways/pull_request"
require "vcr"
require "net/http"

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
rescue LoadError
  p "Could not load RSpec"
end

desc "Send short form dependency audit"
task :dependapanda do
  Dependapanda.new.send_simple_message
end

desc "Send complete dependency audit"
task :dependapanda_loud do
  Dependapanda.new.send_full_message
end

desc "Fetch alphagov repos tagged to govuk"
task :fetch_repos do
  Gateways::Repositories.new.raw_govuk_repos
end

desc "Fetch approved dependabot PR's"
task :fetch_approved_pull_requests do
  Gateways::PullRequest.new.approved_pull_requests
end

desc "Fetch changes requested dependabot PR's"
task :fetch_changes_requested_pull_requests do
  Gateways::PullRequest.new.changes_requested_pull_requests
end

desc "Fetch review required dependabot PR's"
task :fetch_review_required_pull_requests do
  Gateways::PullRequest.new.review_required_pull_requests
end

desc "Fetch all of the data we need from github in a slow way, and write to the cache"
task :warm_the_cache do
  puts "Fetching repos..."
  Rake::Task["fetch_repos"].invoke
  puts "Finished fetching repos."

  puts "Sleeping for 60 seconds to avoid rate-limiting"
  sleep 60

  puts "Fetching approved PRs..."
  Rake::Task["fetch_approved_pull_requests"].invoke
  puts "Finished fetching approved PRs."

  puts "Sleeping for 60 seconds to avoid rate-limiting"
  sleep 60

  puts "Fetching changes requested PRs..."
  Rake::Task["fetch_changes_requested_pull_requests"].invoke
  puts "Finished fetching changes requested PRs."

  puts "Sleeping for 60 seconds to avoid rate-limiting"
  sleep 60

  puts "Fetching review required PRs..."
  Rake::Task["fetch_review_required_pull_requests"].invoke
  puts "Finished fetching review required PRs."
rescue Octokit::Forbidden
  puts "We've been rate limited. Wait 60 seconds and then hit refresh on the app, or run this task again"
end

desc "Flush all data from the memcache server on production. Consider manually refilling the cache with fetch tasks above."
task :flush_cache do
  GovukDependencies.cache.clear
end

desc "Recreate the vcr cassettes. For example `rake record_cassette[org:alphagov topic:govuk]`"
task :record_cassette, [:search_string] do |_, args|
  octokit = Octokit::Client.new(auto_paginate: true)

  puts "Deleting old cassette"
  File.delete("spec/fixtures/vcr_cassettes/repositories.yml") if File.exist?("spec/fixtures/vcr_cassettes/repositories.yml")

  VCR.configure do |config|
    config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
    config.hook_into :webmock
  end

  puts "Recording new cassette"
  VCR.use_cassette("repositories") do
    octokit.search_repos(args[:search_string])
  end
end
