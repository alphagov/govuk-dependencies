require 'slack/poster'

module Gateways
  class SlackMessage
    def execute(message:, channel:)
      slack_poster = Slack::Poster.new(ENV['SLACK_WEBHOOK_URL'], channel: channel)
      slack_poster.send_message(message)
    end
  end
end
