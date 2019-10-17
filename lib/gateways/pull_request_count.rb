module Gateways
  class PullRequestCount
    def initialize
      @octokit = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])
    end

    def execute
      @octokit.search_issues("is:pr user:alphagov author:app/dependabot author:app/dependabot-preview").total_count
    end
  end
end
