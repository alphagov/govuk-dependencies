module Domain
  class PullRequest
    attr_reader :application_name, :title, :open_since, :url, :version

    def initialize(application_name:, title:, opened_at:, url:)
      @application_name = application_name
      @title = title
      @open_since = days_open(opened_at)
      @url = url
      @version = version_from_title(title)
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

    def version_from_title(title)
      title.split(' ').last
    end
  end
end
