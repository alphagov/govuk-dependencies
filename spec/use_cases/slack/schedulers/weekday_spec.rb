describe UseCases::Slack::Schedulers::Weekday do
  context 'Given it is the weekend' do
    it 'does not send messages on Saturday' do
      Timecop.freeze("2018-04-14") do
        expect(subject.should_send_message?).to be false
      end
    end

    it 'does not send messages on Sunday' do
      Timecop.freeze("2018-04-15") do
        expect(subject.should_send_message?).to be false
      end
    end
  end

  context 'Given it is a week day' do
    it 'should_send_slack_messages? is true' do
      Timecop.freeze("2018-04-13") do
        expect(subject.should_send_message?).to be true
      end
    end
  end
end
