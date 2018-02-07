module UseCases
  class SendSlackMessages
    def initialize(
      slack_gateway: Gateways::SlackMessage.new,
      team_gateway: Gateways::Team.new,
      pull_request_gateway: Gateways::PullRequest.new,
      message_presenter:
)
      @slack_gateway = slack_gateway
      @team_gateway = team_gateway
      @pull_request_gateway = pull_request_gateway
      @message_presenter = message_presenter
    end

    def execute(team: nil)
      send_messages(scoped_by_team(pull_requests_by_team, team))
    end

  private

    FALLBACK_TEAM = 'govuk-developers'.freeze

    attr_reader :slack_gateway, :team_gateway, :pull_request_gateway, :message_presenter

    def send_messages(team_pull_requests)
      team_pull_requests.each do |team, pull_requests|
        team_name = team&.team_name || FALLBACK_TEAM
        message = message_presenter.execute(pull_requests: formatted_pull_requests(pull_requests), team_name: team_name)

        slack_gateway.execute(channel: team_name, message: message)
      end
    end

    def pull_requests_by_team
      open_pull_requests = pull_request_gateway.execute
      teams = team_gateway.execute

      open_pull_requests.group_by do |pr|
        team_for_application(teams, pr.application_name)
      end
    end

    def scoped_by_team(pull_requests, team)
      return pull_requests if team.nil?

      pull_requests.select { |pr| pr&.team_name == team }
    end

    def formatted_pull_requests(pull_requests)
      pull_requests.map do |pr|
        {
          application_name: pr.application_name,
          title: pr.title,
          open_since: pr.open_since,
          url: pr.url
        }
      end
    end

    def team_for_application(teams, application_name)
      teams.find { |team| team.applications.include?(application_name) } || teams.find { |team| team.team_name == FALLBACK_TEAM }
    end
  end
end
