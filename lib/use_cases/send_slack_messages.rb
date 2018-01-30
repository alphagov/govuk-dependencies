module UseCases
  class SendSlackMessages
    def initialize(slack_gateway:, team_gateway:, pull_request_gateway:)
      @slack_gateway = slack_gateway
      @team_gateway = team_gateway
      @pull_request_gateway = pull_request_gateway
    end

    def execute
      open_pull_requests = pull_request_gateway.execute
      teams = team_gateway.execute

      pull_requests_by_team = open_pull_requests.group_by do |pr|
        team_for_application(teams, pr.application_name)
      end

      pull_requests_by_team.each do |team, pull_requests|
        team_name = team.team_name.tr('#', '')
        slack_gateway.execute(
          channel: team_name,
          message: "You have #{pull_requests.count} open Dependabot PR(s) - #{url_for_team(team_name)}"
        )
      end
    end

    private

    attr_reader :slack_gateway, :team_gateway, :pull_request_gateway

    def team_for_application(teams, application_name)
      teams.find { |team| team.applications.include?(application_name) }
    end

    def url_for_team(team_name)
      "https://govuk-dependencies.herokuapp.com/team/#{team_name}"
    end
  end
end

