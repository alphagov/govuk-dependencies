module Presenters
  class PullRequestByGem
    def execute(ungrouped_pull_requests)
      grouped_pull_requests = ungrouped_pull_requests.group_by { |pr| gem_name(pr.title) }
      grouped_pull_requests.map do |gem_name, pull_requests|
        {
          gem_name: gem_name,
          pull_requests: pull_requests_for_gem(pull_requests)
        }
      end
    end

  private

    def gem_name(pull_request_title)
      pull_request_title.match('Bump (\S+) from')[1]
    end

    def gem_version(pull_request_title)
      pull_request_title.split(' ').last
    end

    def pull_requests_for_gem(pull_requests)
      pull_requests.map do |pr|
        {
          application_name: pr.application_name,
          version: gem_version(pr.title),
          url: pr.url
        }
      end
    end
  end
end
