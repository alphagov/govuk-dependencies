module UseCases
  class FetchTeams
    def initialize(teams_gateway:)
      @teams_gateway = teams_gateway
    end

    def execute
      teams_gateway.execute
    end

  private

    attr_reader :teams_gateway
  end
end
