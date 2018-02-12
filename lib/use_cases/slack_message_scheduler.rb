module UseCases
  class SlackMessageScheduler
    def initialize(date_class: Date.new)
      @date_class = date_class
    end

    def should_send_message?
      return false if weekend?

      true
    end

  private

    attr_reader :date_class

    def weekend?
      date_class.saturday? || date_class.sunday?
    end
  end
end
