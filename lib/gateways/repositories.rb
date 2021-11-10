require "octokit"

module Gateways
  class Repositories
    def initialize
      @client = GithubClient.new.client
    end

    def execute
      @client.search_repos("org:alphagov topic:govuk").items.map do |repo|
        Domain::Repository.new(name: repo.name, url: repo.url)
      end
    end
  end
end
