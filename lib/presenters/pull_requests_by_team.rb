module Presenters
  class PullRequestsByTeam
    def execute(teams:, ungrouped_pull_requests:)
      pull_requests = pull_requests_by_team(ungrouped_pull_requests, teams)

      sort_by_team_name(applications_by_team(pull_requests))
    end

  private

    def sort_by_team_name(prs)
      prs.sort_by { |team| team[:team_name] }
    end

    def pull_requests_by_team(prs, teams)
      prs.group_by { |pr| team_for_application(teams, pr.fetch(:application_name)) }
    end

    def applications_by_team(prs)
      prs.map do |team, pull_requests|
        applications = application_pull_requests(pull_requests)
        {
          team_name: team&.team_name || 'no team',
          applications: applications.sort_by { |app| [-app[:pull_request_count], app[:application_name]] }
        }
      end
    end

    def application_pull_requests(prs)
      pull_requests_by_application = prs.group_by { |pr| pr.fetch(:application_name) }
      pull_requests_by_application.map do |application_name, pull_request_for_app|
        {
          application_name: application_name,
          application_url: "https://github.com/alphagov/#{application_name}/pulls/app/dependabot",
          pull_request_count: pull_request_for_app.count
        }
      end
    end

    def team_for_application(teams, application_name)
      teams.find { |team| team.applications.include?(application_name) }
    end
  end
end
