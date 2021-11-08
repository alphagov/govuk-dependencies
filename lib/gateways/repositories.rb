module Gateways
  class Repositories
    def initialize
      @client = GithubClient.new.client
    end

    def govuk_repo_urls
      parsed_govuk_repos.map(&:url)
    end

  private

    def parsed_govuk_repos
      @parsed_govuk_repos ||= raw_govuk_repos.map do |repo|
        Domain::Repository.new(name: repo.name, url: repo.url)
      end
    end

    def raw_govuk_repos
      puts "fetch repos!!!!!!!!!!!!!!!!!!!!!!!"
      @raw_govuk_repos ||= CACHE.fetch("govuk-repos", expires_in: 1.hour) do
        @client.search_repos("org:alphagov topic:govuk").items
      end
    end
  end
end
