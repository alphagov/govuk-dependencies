module UseCases
  module Group
    class PullRequestsByDate
      def initialize(fetch_pull_requests: UseCases::PullRequests::Fetch.new)
        @fetch_pull_requests = fetch_pull_requests
      end

      def execute
        prs_sorted_by_application_name
      end

    private

      attr_reader :fetch_pull_requests

      def prs_sorted_by_application_name
        prs_sorted_by_date.each_with_object({}) do |(date, prs), h|
          h[date] = prs.sort_by { |pr| pr[:application_name] }
        end
      end

      def prs_sorted_by_date
        prs_grouped_by_date.sort.to_h
      end

      def prs_grouped_by_date
        ungrouped_prs.group_by { |pr| pr.fetch(:opened_at).strftime("%Y-%m-%d") }
      end

      def ungrouped_prs
        fetch_pull_requests.execute
      end
    end
  end
end
