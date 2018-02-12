module UseCases
  class SendSlackMessages
    def initialize(
      slack_gateway: Gateways::SlackMessage.new,
      team_usecase: UseCases::FetchTeams.new,
      pull_request_usecase: UseCases::FetchPullRequests.new,
      group_applications_by_team_usecase: UseCases::GroupApplicationsByTeam.new,
      scheduler: UseCases::Slack::Schedulers::EveryDay.new,
      message_presenter:
    )

      @slack_gateway = slack_gateway
      @scheduler = scheduler
      @team_usecase = team_usecase
      @pull_request_usecase = pull_request_usecase
      @message_presenter = message_presenter
      @group_applications_by_team_usecase = group_applications_by_team_usecase
    end

    def execute(team: nil)
      return unless scheduler.should_send_message?

      send_messages(scoped_by_team(pull_requests_by_team, team))
    end

  private

    attr_reader :slack_gateway,
      :team_usecase,
      :pull_request_usecase,
      :message_presenter,
      :scheduler,
      :group_applications_by_team_usecase

    def send_messages(applications_by_teams)
      applications_by_teams.each do |applications_by_team|
        slack_gateway.execute(
          channel: applications_by_team.fetch(:team_name),
          message: message_presenter.execute(applications_by_team: applications_by_team)
        )
      end
    end

    def pull_requests_by_team
      group_applications_by_team_usecase.execute(
        pull_requests: pull_request_usecase.execute,
        teams: team_usecase.execute
      )
    end

    def scoped_by_team(pull_requests, team)
      return pull_requests if team.nil?

      pull_requests.select { |pr| pr[:team_name] == team }
    end
  end
end
