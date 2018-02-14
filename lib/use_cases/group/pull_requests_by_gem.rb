module UseCases
  module Group
    class PullRequestsByGem
      def initialize(fetch_pull_requests:)
        @fetch_pull_requests = fetch_pull_requests
      end

      def execute
        grouped_pull_requests = ungrouped_pull_requests.group_by { |pr| gem_name(pr.fetch(:title)) }

        sort_by_gem_name(sort_by_application_name(grouped_pull_requests))
      end

      private

      attr_reader :fetch_pull_requests

      def ungrouped_pull_requests
        fetch_pull_requests.execute
      end

      def sort_by_gem_name(prs)
        prs.sort_by { |gem| gem[:gem_name] }
      end

      def sort_by_application_name(prs)
        prs.map do |gem_name, pull_requests|
          {
            gem_name: gem_name,
            pull_requests: pull_requests.sort_by { |pr| pr[:application_name] }
          }
        end
      end

      def gem_name(pull_request_title)
        pull_request_title.match('Bump (\S+)')[1]
      end
    end
  end
end
