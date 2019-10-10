require "slack/poster"

module Gateways
  class SlackMessage
    def execute(message:, channel:)
      slack_poster = Slack::Poster.new(ENV["SLACK_WEBHOOK_URL"], user_options(channel))
      slack_poster.send_message(message)
    end

    def user_options(channel)
      {
        channel: channel,
        username: "Dependapanda",
        icon_emoji: ":panda_face:",
      }
    end
  end
end
