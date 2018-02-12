describe UseCases::SlackMessageScheduler do
  context 'Given it is the weekend' do
    it 'does not send messages on Saturday' do
      date_class = double(
        saturday?: true,
        sunday?: false
      )

      expect(
        described_class.new(date_class: date_class).should_send_message?
      ).to be false
    end

    it 'does not send messages on Sunday' do
      date_class = double(
        saturday?: false,
        sunday?: true
      )

      expect(
        described_class.new(date_class: date_class).should_send_message?
      ).to be false
    end
  end

  context 'Given it is a week day' do
    it 'should_send_slack_messages? is true' do
      date_class = double(
        saturday?: false,
        sunday?: false,
        monday?: true
      )

      expect(
        described_class.new(date_class: date_class).should_send_message?
      ).to be true
    end
  end
end
