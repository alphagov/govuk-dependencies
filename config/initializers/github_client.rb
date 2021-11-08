require "faraday-http-cache"
require "octokit"

class GithubClient

attr_reader :access_token

  def initialize
    @access_token = ENV["GITHUB_TOKEN"]
  end

  def client(paginate: true)
    load_config
    Octokit::Client.new(access_token: access_token, auto_paginate: paginate)
  end

private

  def load_config
    stack = Faraday::RackBuilder.new do |builder|
      builder.use Faraday::HttpCache, serializer: Marshal, shared_cache: false
      builder.use Octokit::Response::RaiseError
      builder.adapter Faraday.default_adapter
    end
    Octokit.middleware = stack
  end
end
