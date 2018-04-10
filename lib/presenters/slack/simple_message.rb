module Presenters
  module Slack
    class SimpleMessage
      def execute(applications_by_team:)
        "You have #{pull_requests_count(applications_by_team)} open Dependabot PR(s) - #{url(applications_by_team)}"
      end

    private

      def url(applications_by_team)
        "https://govuk-dependencies.herokuapp.com/team/#{applications_by_team.fetch(:team_name)}"
      end

      def pull_requests_count(applications_by_team)
        applications_by_team.fetch(:applications).reduce(0) { |acc, app| acc + app.fetch(:pull_request_count) }
      end
    end
  end
end
