module UseCases
  class FetchPullRequests
    def initialize(gateway: Gateways::PullRequest.new)
      @gateway = gateway
    end

    def execute
      pull_requests = gateway.execute

      pull_requests.map do |result|
        {
          application_name: result.application_name,
          title: result.title,
          url: result.url,
          open_since: result.open_since,
          version: result.version
        }
      end
    end

  private

    attr_reader :gateway
  end
end
