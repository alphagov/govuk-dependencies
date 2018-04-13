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

    def issue_search_common_filters
      'is:pr user:alphagov topic:govuk state:open author:app/dependabot'
    end

    def approved_pull_requests
      approved_pull_requests = @octokit.search_issues("#{issue_search_common_filters} review:approved").items
      build_pull_requests(approved_pull_requests, 'approved')
    end

    def review_required_pull_requests
      review_required_pull_requests = @octokit.search_issues("#{issue_search_common_filters} review:required").items
      build_pull_requests(review_required_pull_requests, 'review required')
    end

    def changes_requested_pull_requests
      changes_requested_pull_requests = @octokit.search_issues("#{issue_search_common_filters} review:changes_requested").items
      build_pull_requests(changes_requested_pull_requests, 'changes requested')
    end

    def build_pull_requests(api_response, status)
      api_response.map do |pr|
        Domain::PullRequest.new(
          application_name: get_application_name(pr),
          title: pr.title,
          url: pr.html_url,
          status: status,
          opened_at: Date.parse(pr.created_at.to_s)
        )
      end
    end

    def get_application_name(pull_request)
      pull_request.repository_url.split('/').last
    end
  end
end
