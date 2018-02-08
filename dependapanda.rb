require_relative 'lib/loader'

class Dependapanda
  def send_simple_message
    UseCases::SendSlackMessages.new(message_presenter: Presenters::Slack::SimpleMessage.new).execute
  end

  def send_full_message
    UseCases::SendSlackMessages.new(message_presenter: Presenters::Slack::FullMessage.new).execute
  end
end
