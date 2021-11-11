module Gateways
  class PullRequest
    def initialize
      @client = GithubClient.new.client
    end

    def execute
      r = review_required_pull_requests
      sleep 10
      a = approved_pull_requests
      sleep 10
      c = changes_requested_pull_requests
      a + c + r
    end

  private

    def approved_pull_requests
      approved_pull_requests = @client.search_issues("is:pr user:alphagov state:open author:app/dependabot author:app/dependabot-preview review:approved").items
      build_pull_requests(approved_pull_requests, "approved")
    end

    def review_required_pull_requests
      prs = fetch_review_required_pull_requests
      build_pull_requests(prs, "review required")
    end

    def changes_requested_pull_requests
      changes_requested_pull_requests = @client.search_issues("is:pr user:alphagov state:open author:app/dependabot author:app/dependabot-preview review:changes_requested").items
      build_pull_requests(changes_requested_pull_requests, "changes requested")
    end

    def fetch_review_required_pull_requests
      @client_without_pagination = GithubClient.new.client(auto_paginate: false)
      @client_without_pagination.search_issues("is:pr user:alphagov state:open author:app/dependabot author:app/dependabot-preview review:required", per_page: 100)

      last_response = @client_without_pagination.last_response
      return [] if last_response.data.items.empty?

      pulls = []
      pulls << last_response.data.items

      until last_response.rels[:next].nil?
        sleep 10 if (current_page(last_response) % 3).zero?
        last_response = last_response.rels[:next].get
        pulls << last_response.data.items
      end
      pulls.flatten
    end

    def current_page(response)
      response.rels[:next].href.match(/(?<!per_)page=(\d+)/)[1].to_i
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
      pull_request.repository_url.split("/").last
    end
  end
end
