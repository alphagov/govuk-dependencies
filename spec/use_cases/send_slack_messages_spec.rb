describe UseCases::SendSlackMessages do
  context 'given no teams or pull requests' do
    it 'does not call the slack gateway' do
      team_gateway = double(execute: [])
      pull_request_gateway = double(execute: [])
      slack_gateway = double
      expect(slack_gateway).not_to receive(:execute)
      described_class.new(
        slack_gateway: slack_gateway,
        team_gateway: team_gateway,
        pull_request_gateway: pull_request_gateway
      ).execute
    end
  end

  context 'given one team' do
    context 'and no pull requests' do
      it 'does not call the slack gateway' do
        team_gateway = double(execute: [
          Domain::Team.new(team_name: '#email', applications: ['whitehall'])
        ])
        pull_request_gateway = double(execute: [])
        slack_gateway = double
        expect(slack_gateway).not_to receive(:execute)
        described_class.new(
          slack_gateway: slack_gateway,
          team_gateway: team_gateway,
          pull_request_gateway: pull_request_gateway
        ).execute
      end
    end

    context 'and one pull request' do
      it 'sends a single message with one pull request open' do
        team_gateway = double(execute: [
          Domain::Team.new(team_name: '#email', applications: ['whitehall'])
        ])
        pull_request_gateway = double(execute: [
          Domain::PullRequest.new(
            application_name: 'whitehall',
            title: 'Bump foo 1.2.3 to 4.5.6',
            opened_at: Date.parse('2018-01-25'),
            url: 'https://github.com/alphagov/whitehall/123'
          )
        ])
        slack_gateway = double
        slack_message = 'You have 1 open Dependabot PR(s) - https://govuk-dependencies.herokuapp.com/team/email'

        expect(slack_gateway).to receive(:execute).with(
          team: 'email',
          message: slack_message
        )
        described_class.new(
          slack_gateway: slack_gateway,
          team_gateway: team_gateway,
          pull_request_gateway: pull_request_gateway
        ).execute
      end
    end

    context 'multiple pull requests for one team' do
      it 'sends a single message' do
        team_gateway = double(execute: [
          Domain::Team.new(team_name: '#email', applications: ['whitehall'])
        ])
        pull_request_gateway = double(execute: [
          Domain::PullRequest.new(
            application_name: 'whitehall',
            title: 'Bump foo 1.2.3 to 4.5.6',
            opened_at: Date.parse('2018-01-25'),
            url: 'https://github.com/alphagov/whitehall/123'
          ),

          Domain::PullRequest.new(
            application_name: 'whitehall',
            title: 'Bump Rails from 4.2.1 to 5.1.0',
            opened_at: Date.parse('2018-01-25'),
            url: 'https://github.com/alphagov/whitehall/123'
          )
        ])
        slack_gateway = double
        slack_message = 'You have 2 open Dependabot PR(s) - https://govuk-dependencies.herokuapp.com/team/email'
        expect(slack_gateway).to receive(:execute).with(
          team: 'email',
          message: slack_message
        )
        described_class.new(
          slack_gateway: slack_gateway,
          team_gateway: team_gateway,
          pull_request_gateway: pull_request_gateway
        ).execute
      end
    end
  end

  context 'multiple pull requests for multiple teams' do
    it 'sends one message to each team' do
      team_gateway = double(execute: [
        Domain::Team.new(team_name: '#email', applications: ['whitehall']),
        Domain::Team.new(team_name: '#platform_support', applications: ['travel-advice-publisher'])
      ])
      pull_request_gateway = double(execute: [
        Domain::PullRequest.new(
          application_name: 'whitehall',
          title: 'Bump foo 1.2.3 to 4.5.6',
          opened_at: Date.parse('2018-01-25'),
          url: 'https://github.com/alphagov/whitehall/123'
        ),
        Domain::PullRequest.new(
          application_name: 'whitehall',
          title: 'Bump Rails from 4.2.1 to 5.1.0',
          opened_at: Date.parse('2018-01-25'),
          url: 'https://github.com/alphagov/whitehall/457'
        ),

        Domain::PullRequest.new(
          application_name: 'travel-advice-publisher',
          title: 'Bump Rails from 1.3.4 to 2.0.0',
          opened_at: Date.parse('2018-01-25'),
          url: 'https://github.com/alphagov/travel-advice-publisher/123'
        )
      ])
      slack_gateway = double
      email_slack_message = 'You have 2 open Dependabot PR(s) - https://govuk-dependencies.herokuapp.com/team/email'
      platform_slack_message = 'You have 1 open Dependabot PR(s) - https://govuk-dependencies.herokuapp.com/team/platform_support'
      expect(slack_gateway).to receive(:execute).with(
        team: 'email',
        message: email_slack_message
      )
      expect(slack_gateway).to receive(:execute).with(
        team: 'platform_support',
        message: platform_slack_message
      )

      described_class.new(
        slack_gateway: slack_gateway,
        team_gateway: team_gateway,
        pull_request_gateway: pull_request_gateway
      ).execute
    end
  end
end

