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
        slack_gateway.execute(
          team: team.team_name.tr('#', ''),
          message: "You have #{pull_requests.count} open Dependabot PR(s)"
        )
      end
    end

  private

    attr_reader :slack_gateway, :team_gateway, :pull_request_gateway

    def team_for_application(teams, application_name)
      teams.find { |team| team.applications.include?(application_name) }
    end
  end
end
