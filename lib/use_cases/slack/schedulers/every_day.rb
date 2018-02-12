module UseCases
  module Slack
    module Schedulers
      class EveryDay
        def should_send_message?
          true
        end
      end
    end
  end
end
