require "octokit"

class GithubClient
  def initialize
    @access_token = ENV["GITHUB_TOKEN"]
  end

  def client(auto_paginate: true)
    Octokit::Client.new(access_token: access_token, auto_paginate: auto_paginate)
  end

private

  attr_reader :access_token
end
