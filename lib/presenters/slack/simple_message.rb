module Presenters
  module Slack
    class SimpleMessage
      def execute(pull_requests:, team_name:)
        "You have #{pull_requests.count} open Dependabot PR(s) - #{url_for_team(team_name)} - Feedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback"
      end

    private

      def url_for_team(team_name)
        "https://govuk-dependencies.herokuapp.com/team/#{team_name}"
      end
    end
  end
end
