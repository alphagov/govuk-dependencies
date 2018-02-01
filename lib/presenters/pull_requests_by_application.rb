module Presenters
  class PullRequestsByApplication
    def execute(ungrouped_pull_requests)
      grouped_pull_requests = ungrouped_pull_requests.group_by do |value|
        value.fetch(:application_name)
      end

      sort_by_application_name(sort_by_pull_request_title(grouped_pull_requests))
    end

  private

    def sort_by_application_name(prs)
      prs.sort_by { |app| app[:application_name] }
    end

    def sort_by_pull_request_title(prs)
      prs.map do |application_name, pull_requests|
        {
          application_name: application_name,
          application_url: application_url(application_name),
          pull_requests: pull_requests.sort_by { |pr| pr[:title] }
        }
      end
    end

    def application_url(application_name)
      "https://github.com/alphagov/#{application_name}/pulls"
    end
  end
end
