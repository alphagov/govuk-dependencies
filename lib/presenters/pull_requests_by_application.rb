module Presenters
  class PullRequestsByApplication
    def execute(ungrouped_pull_requests)
      grouped_pull_requests = ungrouped_pull_requests.group_by(&:application_name)

      grouped_pull_requests.map do |application_name, pull_requests|
        {
          application_name: application_name,
          application_url: application_url(application_name),
          pull_requests: pull_requests
        }
      end
    end

  private

    def application_url(application_name)
      "https://github.com/alphagov/#{application_name}/pulls"
    end
  end
end
