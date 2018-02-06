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

    def execute
      open_pull_requests = pull_request_gateway.execute
      teams = team_gateway.execute

      pull_requests_by_team = open_pull_requests.group_by do |pr|
        team_for_application(teams, pr.application_name)
      end

      pull_requests_by_team.each do |team, pull_requests|
        team_name = team&.team_name || FALLBACK_TEAM
        message = message_presenter.execute(pull_requests: formatted_pull_requests(pull_requests), team_name: team_name)

        slack_gateway.execute(channel: team_name, message: message)
      end
    end

  private

    FALLBACK_TEAM = 'govuk-developers'.freeze

    attr_reader :slack_gateway, :team_gateway, :pull_request_gateway, :message_presenter

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
