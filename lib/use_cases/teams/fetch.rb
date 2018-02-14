module UseCases
  module Teams
    class Fetch
      def initialize(teams_gateway: Gateways::Team.new)
        @teams_gateway = teams_gateway
      end

      def execute
        teams = teams_gateway.execute

        teams.map do |team|
          {
            team_name: team.team_name,
            applications: team.applications
          }
        end
      end

      private

      attr_reader :teams_gateway
    end
  end
end
