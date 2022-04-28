module Gateways
  class PullRequestCount
    def initialize
      @client = GithubClient.new.client(auto_paginate: false)
    end

    def execute
      @client.search_issues("is:pr user:alphagov author:app/dependabot").total_count
    end
  end
end
