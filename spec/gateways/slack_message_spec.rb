describe Gateways::SlackMessage do
  context 'Given a message to post and a channel to post to' do
    it 'posts the message to the slack webhook' do
      ENV['SLACK_WEBHOOK_URL'] = 'http://example.com/webhook'
      slack_channel = "#email"
      slack_message = "#email has 12 open pull requests"
      body = {
        "payload" =>
          '{"channel":"#email","username":"Dependaseal","icon_emoji":":panda_face:","text":"#email has 12 open pull requests"}'
      }

      stub_request(:post, "http://example.com/webhook").
        with(body: body).
      to_return(status: 200, body: "", headers: {})

      described_class.new.execute(message: slack_message, channel: slack_channel)
      expect(a_request(:post, ENV['SLACK_WEBHOOK_URL']).with(body: body)).to have_been_made
    end
  end
end
