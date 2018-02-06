module Presenters
  module Slack
    class FullMessage
      def execute(pull_requests:, team_name:)
        "##{team_name} You have #{pull_requests.count} Dependabot PRs open on the following apps:

#{body(grouped_by_application(pull_requests)).join("\n")}

Feedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback"
      end

    private

      def grouped_by_application(prs)
        prs.group_by { |pr| pr.fetch(:application_name) }
      end

      def body(pull_requests)
        pull_requests.map do |application_name, _|
          application_name + ' ' + url(application_name)
        end
      end

      def url(application_name)
        "https://github.com/alphagov/#{application_name}/pulls/app/dependabot"
      end
    end
  end
end
