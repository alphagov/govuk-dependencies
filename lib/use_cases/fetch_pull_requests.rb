module UseCases
  class FetchPullRequests
    def initialize(gateway: Gateways::PullRequest.new)
      @gateway = gateway
    end

    def execute
      gateway.execute.map do |result|
        {
          application_name: result.application_name,
          title: result.title,
          url: result.url,
          open_since: result.open_since
        }
      end
    end

  private

    attr_reader :gateway
  end
end
