module Presenters
  class PullRequestsByApplication
    def execute(ungrouped_pull_requests)
      grouped_pull_requests = ungrouped_pull_requests.group_by do |value|
        value.fetch(:application_name)
      end

      pull_requests_by_application = grouped_pull_requests.map do |application_name, pull_requests|
        {
          application_name: application_name,
          application_url: application_url(application_name),
          pull_requests: pull_requests.sort_by { |pr| pr[:title] }
        }
      end
      pull_requests_by_application.sort_by { |app| app[:application_name] }
    end

  private

    def application_url(application_name)
      "https://github.com/alphagov/#{application_name}/pulls"
    end
  end
end
