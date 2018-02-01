module Presenters
  class PullRequestsByGem
    def execute(ungrouped_pull_requests)
      grouped_pull_requests = ungrouped_pull_requests.group_by { |pr| gem_name(pr.fetch(:title)) }
      pull_requests_by_gem = grouped_pull_requests.map do |gem_name, pull_requests|
        {
          gem_name: gem_name,
          pull_requests: pull_requests.sort_by { |pr| pr[:application_name] }
        }
      end
      pull_requests_by_gem.sort_by { |gem| gem[:gem_name] }
    end

  private

    def gem_name(pull_request_title)
      pull_request_title.match('Bump (\S+)')[1]
    end
  end
end
