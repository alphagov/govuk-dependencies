module Presenters
  module Slack
    class FullMessage
      def execute(applications_by_team:, continuously_deployed_apps: [])
        applications = applications_by_team.fetch(:applications)
        cd_apps = applications.filter { |app| continuously_deployed_apps.include?(app.fetch(:application_name)) }
        if pull_requests_count(cd_apps).positive?
          "#{url_for_team(applications_by_team)} have #{pull_requests_count(cd_apps)} Dependabot PRs open on the following Continuously Deployed apps:

#{body(cd_apps).join(' ')}

And #{pull_requests_count(applications) - pull_requests_count(cd_apps)} Dependabot PRs open on other apps:

#{body(applications - cd_apps).join(' ')}"
        else
          "#{url_for_team(applications_by_team)} have #{pull_requests_count(applications)} Dependabot PRs open on the following apps:

#{body(applications).join(' ')}"
        end
      end

    private

      def body(applications)
        applications.map do |application|
          application_name = application.fetch(:application_name)
          "<#{url(application_name)}|#{application_name}> (#{application.fetch(:pull_request_count)})"
        end
      end

      def url(application_name)
        "https://github.com/alphagov/#{application_name}/pulls?q=is:pr+is:open+label:dependencies"
      end

      def url_for_team(applications_by_team)
        team_name = applications_by_team.fetch(:team_name)
        "<https://govuk-dependencies.herokuapp.com/team/#{team_name}|#{team_name}>"
      end

      def pull_requests_count(applications)
        applications.reduce(0) { |acc, pr| acc + pr.fetch(:pull_request_count) }
      end
    end
  end
end
