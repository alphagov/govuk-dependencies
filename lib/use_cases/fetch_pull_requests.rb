module UseCases
  class FetchPullRequests
    def initialize(gateway:)
      @gateway = gateway
    end

    def execute
      gateway.execute
    end

  private

    attr_reader :gateway
  end
end
