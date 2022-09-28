require "slack/poster"

module Gateways
  class SlackMessage
    class PostError < RuntimeError
    end

    def execute(message:, channel:)
      slack_poster = Slack::Poster.new(ENV["SLACK_WEBHOOK_URL"], user_options(channel))
      response = slack_poster.send_message(message)
      unless response.success?
        raise PostError, response.body
      end
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
