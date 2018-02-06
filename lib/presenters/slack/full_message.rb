module Presenters
  module Slack
    class FullMessage
      def execute(pull_requests:, team_name:)
        [header(team_name), body(pull_requests), footer].flatten.join("\n")
      end

    private

      def header(team_name)
        "##{team_name}\n"
      end

      def body(pull_requests)
        pull_requests.map do |pr|
          pr.fetch(:application_name) + ' ' + url(pr.fetch(:application_name))
        end
      end

      def footer
        "\nFeedback: #{feedback_url}"
      end

      def url(application_name)
        "https://github.com/alphagov/#{application_name}/pulls/app/dependabot"
      end

      def feedback_url
        'https://trello.com/b/jQrIfH9A/dependabot-developer-feedback'
      end

      def team_for_application(teams, application_name)
        teams.find { |team| team.applications.include?(application_name) }
      end
    end
  end
end
