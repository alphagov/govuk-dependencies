module Presenters
  module Slack
    class FullMessage
      def execute(applications_by_team:)
        "#{url_for_team(applications_by_team)} have #{pull_requests_count(applications_by_team)} Dependabot PRs open on the following apps:

#{body(applications_by_team).join(' ')}"
      end

    private

      def body(applications_by_team)
        applications_by_team.fetch(:applications).map do |application|
          application_name = application.fetch(:application_name)
          "<#{url(application_name)}|#{application_name}> (#{application.fetch(:pull_request_count)})"
        end
      end

      def url(application_name)
        "https://github.com/alphagov/#{application_name}/pulls?is:pr+is:open+label:dependencies"
      end

      def url_for_team(applications_by_team)
        team_name = applications_by_team.fetch(:team_name)
        "<https://govuk-dependencies.herokuapp.com/team/#{team_name}|#{team_name}>"
      end

      def pull_requests_count(applications_by_team)
        applications_by_team.fetch(:applications).reduce(0) { |acc, pr| acc + pr.fetch(:pull_request_count) }
      end
    end
  end
end
