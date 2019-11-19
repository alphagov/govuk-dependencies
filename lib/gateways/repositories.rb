require "octokit"

module Gateways
  class Repositories
    def initialize
      @octokit = Octokit::Client.new(
        access_token: ENV.fetch("DEPENDENCIES_GITHUB_TOKEN"),
        auto_paginate: true,
      )
    end

    def execute
      @octokit.search_repos("org:alphagov topic:govuk").items.map do |repo|
        Domain::Repository.new(name: repo.name, url: repo.url)
      end
    end
  end
end
