module UseCases
  class FetchPullRequestCount
    def initialize(pull_request_count_gateway: Gateways::PullRequestCount.new)
      @pull_request_count_gateway = pull_request_count_gateway
    end

    def execute
      pull_request_count_gateway.execute
    end

  private

    attr_reader :pull_request_count_gateway
  end
end
