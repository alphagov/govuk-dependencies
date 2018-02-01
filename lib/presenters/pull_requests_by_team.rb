module Presenters
  class PullRequestsByTeam
    def execute(teams:, ungrouped_pull_requests:)
      pull_requests_by_team = ungrouped_pull_requests.group_by { |pr| team_for_application(teams, pr.fetch(:application_name)) }
      pull_requests_by_team.map do |team, pull_requests|
        pull_requests_by_application = pull_requests.group_by { |pr| pr.fetch(:application_name) }

        {
          team_name: team&.team_name || 'no team',
          applications: pull_requests_by_application.map do |application_name, pull_request_for_app|
            {
              application_name: application_name,
              application_url: "https://github.com/alphagov/#{application_name}/pulls/app/dependabot",
              pull_request_count: pull_request_for_app.count
            }
          end
        }
      end
    end

  private

    def team_for_application(teams, application_name)
      teams.find { |team| team.applications.include?(application_name) }
    end
  end
end
