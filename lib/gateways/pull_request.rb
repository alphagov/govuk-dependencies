require 'octokit'

module Gateways
  class PullRequest
    def initialize
      @octokit = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'], auto_traversal: true, per_page: 100)
    end

    def execute
      response = @octokit.search_issues('is:pr user:alphagov state:open author:app/dependabot').items
      build_pull_requests(response)
    end

  private

    def build_pull_requests(api_response)
      api_response.map do |pr|
        Domain::PullRequest.new(
          application_name: get_application_name(pr),
          title: pr.title,
          url: pr.html_url,
          opened_at: Date.parse(pr.created_at.to_s)
        )
      end
    end

    def get_application_name(pull_request)
      pull_request.repository_url.split('/').last
    end
  end
end
