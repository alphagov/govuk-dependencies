module UseCases
  class FetchPullRequests
    def initialize(gateway: Gateways::PullRequest.new)
      @gateway = gateway
    end

    def execute
      pull_request_hash = gateway.execute.map do |result|
        {
          application_name: result.application_name,
          title: result.title,
          url: result.url,
          open_since: result.open_since
        }
      end

      split_summarised_pull_requests(pull_request_hash)
    end

  private

    SUMMARISED_PR_TITLE_MATCH = 'Bump (\S+) and (\S+)'.freeze

    def split_summarised_pull_requests(pull_requests)
      pull_requests.map { |pr| split_pull_request(pr) }.flatten
    end

    def split_pull_request(pr)
      return pr unless two_gems_bumped?(pr)

      gems = pr[:title].match(SUMMARISED_PR_TITLE_MATCH)

      [
        pr.merge(title: "Bump #{gems[1]}"),
        pr.merge(title: "Bump #{gems[2]}")
      ]
    end

    def two_gems_bumped?(pr)
      pr[:title].match?(SUMMARISED_PR_TITLE_MATCH)
    end

    attr_reader :gateway
  end
end
