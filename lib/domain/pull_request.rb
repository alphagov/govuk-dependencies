module Domain
  class PullRequest
    attr_reader :application_name, :title, :opened_at, :open_since, :status, :url

    def initialize(application_name:, title:, opened_at:, url:, status:)
      @application_name = application_name
      @title = title
      @opened_at = opened_at
      @open_since = days_open(opened_at)
      @status = status
      @url = url
    end

  private

    def days_open(opened_at)
      days = (Date.today - opened_at).to_i
      case days
      when 0
        'today'
      when 1
        'yesterday'
      else
        "#{days} days ago"
      end
    end
  end
end
