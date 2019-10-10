module UseCases
  module PullRequests
    class Fetch
      def initialize(gateway: Gateways::PullRequest.new)
        @gateway = gateway
      end

      def execute
        pull_request_hash = gateway.execute.map do |result|
          {
            application_name: result.application_name,
            title: result.title,
            url: result.url,
            status: result.status,
            opened_at: result.opened_at,
            open_since: result.open_since,
          }
        end

        split_summarised_pull_requests(pull_request_hash)
      end

    private

      SINGLE_GEM_TITLE_MATCH = 'Bump \S+ from \S+ to \S+'.freeze

      def split_summarised_pull_requests(pull_requests)
        pull_requests.map { |pr| split_pull_request(pr) }.flatten
      end

      def split_pull_request(pull_request)
        return pull_request if one_gem_bumped?(pull_request)

        gems_from_title(pull_request[:title]).map { |gem| pull_request.merge(title: "Bump #{gem.strip}") }
      end

      def one_gem_bumped?(pull_request)
        pull_request[:title].match?(SINGLE_GEM_TITLE_MATCH)
      end

      def gems_from_title(title)
        title.sub("Bump ", "").sub("and", ",").split(",")
      end

      attr_reader :gateway
    end
  end
end
