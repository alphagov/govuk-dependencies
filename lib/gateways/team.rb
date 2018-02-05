require 'net/http'
require 'json'

module Gateways
  class Team
    def initialize
      @endpoint = URI('https://docs.publishing.service.gov.uk/apps.json')
    end

    def execute
      api_response = Net::HTTP.get(endpoint)
      teams = JSON.parse(api_response)

      grouped_teams = teams.group_by { |team| team['team'] }
      grouped_teams.map do |team_name, team_info|
        Domain::Team.new(
          team_name: team_name.tr('#', ''),
          applications: team_info.map { |info| info['app_name'] }
        )
      end
    end

  private

    attr_reader :endpoint
  end
end
