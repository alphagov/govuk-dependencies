module UseCases
  module Slack
    module Schedulers
      class Weekday
        def should_send_message?
          !weekend?
        end

      private

        def weekend?
          date = Time.now
          date.saturday? || date.sunday?
        end
      end
    end
  end
end
