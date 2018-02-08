module Presenters
  module Slack
    class FullMessage
      def execute(applications_by_team:)
        "You have #{pull_requests_count(applications_by_team)} Dependabot PRs open on the following apps:

#{body(applications_by_team).join("\n")}

Feedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback"
      end

    private

      def body(applications_by_team)
        applications_by_team.fetch(:applications).map do |application|
          application_name = application.fetch(:application_name)
          "<#{url(application_name)}|#{application_name}> (#{application.fetch(:pull_request_count)})"
        end
      end

      def url(application_name)
        "https://github.com/alphagov/#{application_name}/pulls/app/dependabot"
      end

      def pull_requests_count(applications_by_team)
        applications_by_team.fetch(:applications).reduce(0) { |acc, pr| acc + pr.fetch(:pull_request_count) }
      end
    end
  end
end
