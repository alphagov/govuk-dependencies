module Presenters
  class PullRequestsByApplication
    def execute(ungrouped_pull_requests)
      grouped_pull_requests = ungrouped_pull_requests.group_by(&:application_name)

      grouped_pull_requests.map do |application_name, pull_requests|
        {
          application_name: application_name,
          pull_requests: pull_requests
        }
      end
    end
  end
end
