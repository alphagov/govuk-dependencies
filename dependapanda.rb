require_relative 'lib/loader'

class Dependapanda
  def send_simple_message
    UseCases::SendSlackMessages.new(
      message_presenter: Presenters::Slack::SimpleMessage.new,
      scheduler: UseCases::Slack::Schedulers::Weekday.new
    ).execute
  end

  def send_full_message
    UseCases::SendSlackMessages.new(
      message_presenter: Presenters::Slack::FullMessage.new,
      scheduler: UseCases::Slack::Schedulers::Weekday.new
    ).execute
  end
end
