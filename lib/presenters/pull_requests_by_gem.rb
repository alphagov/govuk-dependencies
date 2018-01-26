module Presenters
  class PullRequestsByGem
    def execute(ungrouped_pull_requests)
      grouped_pull_requests = ungrouped_pull_requests.group_by { |pr| gem_name(pr.title) }
      grouped_pull_requests.map do |gem_name, pull_requests|
        {
          gem_name: gem_name,
          pull_requests: pull_requests
        }
      end
    end

  private

    def gem_name(pull_request_title)
      pull_request_title.match('Bump (\S+) from')[1]
    end
  end
end
