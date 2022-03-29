require "net/http"
require "json"

module Gateways
  class Team
    def initialize
      @endpoint = URI("https://docs.publishing.service.gov.uk/repos.json")
      @default_team_name = "#govuk-developers"
    end

    def execute
      teams.map do |name, apps|
        Domain::Team.new(
          team_name: (name || default_team_name).tr("#", ""),
          applications: apps.map { |app| app["app_name"] },
          continuously_deployed_apps: apps.filter { |app| app["continuously_deployed"] }.map { |app| app["app_name"] },
        )
      end
    end

  private

    attr_reader :endpoint, :default_team_name

    def teams
      api_response = Net::HTTP.get(endpoint)
      apps = JSON.parse(api_response)
      apps.group_by { |app| app["dependencies_team"] }
    end
  end
end
