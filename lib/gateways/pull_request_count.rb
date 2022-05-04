module Gateways
  class PullRequestCount
    def initialize
      @client = GithubClient.new.client(auto_paginate: false)
    end

    def execute
      @client.search_issues("is:pr user:alphagov state:open author:app/dependabot archived:false").total_count
    end
  end
end
