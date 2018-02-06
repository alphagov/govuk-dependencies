describe Presenters::Slack::SimpleMessage do
  context 'Given a single pull request and a team' do
    it 'formats the message' do
      team_name = 'email'

      result = described_class.new.execute(pull_requests: [double], team_name: team_name)

      expect(result).to eq('You have 1 open Dependabot PR(s) - https://govuk-dependencies.herokuapp.com/team/email - Feedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback')
    end
  end
end
