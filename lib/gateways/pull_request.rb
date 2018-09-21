require 'octokit'

module Gateways
  class PullRequest
    def initialize
      @octokit = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'], auto_paginate: true)
    end

    def execute
      approved_pull_requests + review_required_pull_requests + changes_requested_pull_requests
    end

  private

    def approved_pull_requests
      approved_pull_requests = @octokit.search_issues('is:pr user:alphagov state:open author:app/dependabot review:approved').items
      build_pull_requests(approved_pull_requests, 'approved')
    end

    def review_required_pull_requests
      review_required_pull_requests = @octokit.search_issues('is:pr user:alphagov state:open author:app/dependabot review:required').items
      build_pull_requests(review_required_pull_requests, 'review required')
    end

    def changes_requested_pull_requests
      changes_requested_pull_requests = @octokit.search_issues('is:pr user:alphagov state:open author:app/dependabot review:changes_requested').items
      build_pull_requests(changes_requested_pull_requests, 'changes requested')
    end

    def build_pull_requests(api_response, status)
      api_response
        .select { |pr| govuk_repository_urls.include?(pr.repository_url) }
        .map do |pr|
          Domain::PullRequest.new(
            application_name: get_application_name(pr),
            title: pr.title,
            url: pr.html_url,
            status: status,
            opened_at: Date.parse(pr.created_at.to_s),
          )
        end
    end

    def govuk_repository_urls
      @govuk_repository_urls ||= Gateways::Repositories.new.execute.map(&:url)
    end

    def get_application_name(pull_request)
      pull_request.repository_url.split('/').last
    end
  end
end
