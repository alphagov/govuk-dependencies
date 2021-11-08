module Gateways
  class PullRequest

    def initialize
      @client = GithubClient.new.client(paginate: false)
    end

    def execute
      approved_pull_requests + changes_requested_pull_requests + review_required_pull_requests
    end

  private

    def approved_pull_requests
      puts "approved_pull_requests!!!!!!!!!!!"
      @approved_pull_requests ||= CACHE.fetch("approved-prs", expires_in: 1.hour) do
        @client.search_issues("is:pr user:alphagov state:open author:app/dependabot author:app/dependabot-preview review:approved").items
      end
      build_pull_requests(@approved_pull_requests, "approved")
    end

    def review_required_pull_requests

      puts "review_required_pull_requests!!!!!!!!!!!!!!"
      @review_required_pull_requests ||= CACHE.fetch("review-required-prs", expires_in: 1.hour) do
        fetch_review_required_pull_requests
      end
      build_pull_requests(@review_required_pull_requests, "review required")
    end

    def fetch_review_required_pull_requests
      @client.search_issues("is:pr user:alphagov state:open author:app/dependabot author:app/dependabot-preview review:required", per_page: 100)

      last_response = @client.last_response

      pulls = []

      pulls << last_response.data.items
      until last_response.rels[:next].nil?
        sleep 10
        puts last_response.rels[:next].href
        last_response = last_response.rels[:next].get
        pulls << last_response.data.items
      end
      pulls.flatten
    end

    def changes_requested_pull_requests
      puts "changes_requested_pull_requests!!!!!!!!!!!"
      @changes_requested_pull_requests ||= CACHE.fetch("changes-requested-prs", expires_in: 1.hour) do
        @client.search_issues("is:pr user:alphagov state:open author:app/dependabot author:app/dependabot-preview review:changes_requested").items
      end
      build_pull_requests(@changes_requested_pull_requests, "changes requested")
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
      @govuk_repository_urls ||= Gateways::Repositories.new.govuk_repo_urls
    end

    def get_application_name(pull_request)
      pull_request.repository_url.split("/").last
    end
  end
end
