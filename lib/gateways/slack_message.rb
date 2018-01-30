require 'slack/poster'

module Gateways
  class SlackMessage
    def execute(message:, channel:)
      slack_poster = Slack::Poster.new(
        ENV['SLACK_WEBHOOK_URL'],
        channel: channel,
        options: user_options
      )
      slack_poster.send_message(message)
    end

    def user_options
      {
        username: 'Dependaseal',
        icon_emoji: ':happyseal:'
      }
    end
  end
end
