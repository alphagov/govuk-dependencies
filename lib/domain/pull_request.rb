module Domain
  class PullRequest
    attr_reader :application_name, :title, :opened_at, :url

    def initialize(application_name:, title:, opened_at:, url:)
      @application_name = application_name
      @title = title
      @opened_at = opened_at
      @url = url
    end
  end
end
