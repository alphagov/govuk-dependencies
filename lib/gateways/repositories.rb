require_relative "../../app"

module Gateways
  class Repositories
    def initialize
      @client = GithubClient.new.client
    end

    def govuk_repo_urls
      parsed_govuk_repos.map(&:url)
    end

    def parsed_govuk_repos
      @parsed_govuk_repos ||= raw_govuk_repos.map do |repo|
        Domain::Repository.new(name: repo.name, url: repo.url)
      end
    end

    def raw_govuk_repos
      @raw_govuk_repos ||= GovukDependencies.cache.fetch("govuk-repos") do
        repos = @client.search_repos("org:alphagov topic:govuk").items
        GovukDependencies.cache.write("govuk-repos", repos)
        repos
      end
    end
  end
end
