module Presenters
  module Slack
    class FullMessage
      def execute(pull_requests:, team_name:)
        "##{team_name}

#{body(pull_requests).join("\n")}

Feedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback"
      end

    private

      def body(pull_requests)
        pull_requests.map do |pr|
          pr.fetch(:application_name) + ' ' + url(pr.fetch(:application_name))
        end
      end

      def url(application_name)
        "https://github.com/alphagov/#{application_name}/pulls/app/dependabot"
      end
    end
  end
end
