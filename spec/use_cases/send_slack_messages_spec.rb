describe UseCases::SendSlackMessages do
  context 'given no teams or pull requests' do
    it 'does not call the slack gateway' do
      team_gateway = double(execute: [])
      pull_request_gateway = double(execute: [])
      slack_gateway = double
      message_presenter = double
      expect(slack_gateway).not_to receive(:execute)
      described_class.new(
        slack_gateway: slack_gateway,
        team_gateway: team_gateway,
        pull_request_gateway: pull_request_gateway,
        message_presenter: message_presenter
      ).execute
    end
  end

  context 'given one team' do
    context 'and no pull requests' do
      it 'does not call the slack gateway' do
        team_gateway = double(execute: [
          Domain::Team.new(team_name: 'email', applications: ['whitehall'])
        ])
        pull_request_gateway = double(execute: [])
        slack_gateway = double
        message_presenter = double
        expect(slack_gateway).not_to receive(:execute)
        described_class.new(
          slack_gateway: slack_gateway,
          team_gateway: team_gateway,
          pull_request_gateway: pull_request_gateway,
          message_presenter: message_presenter
        ).execute
      end
    end

    context 'and one pull request' do
      it 'sends a single message with one pull request open' do
        team_gateway = double(execute: [
          Domain::Team.new(team_name: 'email', applications: ['whitehall'])
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
        message_presenter = double(execute: 'some message')

        expect(slack_gateway).to receive(:execute).with(channel: 'email', message: 'some message')

        described_class.new(
          slack_gateway: slack_gateway,
          team_gateway: team_gateway,
          pull_request_gateway: pull_request_gateway,
          message_presenter: message_presenter
        ).execute
      end
    end

    context 'multiple pull requests for one team' do
      it 'sends a single message' do
        team_gateway = double(execute: [
          Domain::Team.new(team_name: 'email', applications: ['whitehall'])
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
        message_presenter = double(execute: 'some message')
        expect(slack_gateway).to receive(:execute).with(
          channel: 'email',
          message: 'some message'
        )
        described_class.new(
          slack_gateway: slack_gateway,
          team_gateway: team_gateway,
          pull_request_gateway: pull_request_gateway,
          message_presenter: message_presenter
        ).execute
      end
    end
  end

  context 'multiple pull requests for multiple teams' do
    it 'sends one message to each team' do
      team_gateway = double(execute: [
        Domain::Team.new(team_name: 'email', applications: ['whitehall']),
        Domain::Team.new(team_name: 'platform_support', applications: ['travel-advice-publisher'])
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
      slack_message = 'some message'
      message_presenter = double(execute: slack_message)

      expect(slack_gateway).to receive(:execute).with(
        channel: 'email',
        message: slack_message
      )
      expect(slack_gateway).to receive(:execute).with(
        channel: 'platform_support',
        message: slack_message
      )

      described_class.new(
        slack_gateway: slack_gateway,
        team_gateway: team_gateway,
        pull_request_gateway: pull_request_gateway,
        message_presenter: message_presenter
      ).execute
    end
  end

  context 'given pull requests which have no team' do
    context 'with no other pull requests' do
      it 'sends a message to govuk-developers' do
        team_gateway = double(execute: [
          Domain::Team.new(team_name: 'non_existent_team', applications: ['travel-advice-publisher'])
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
        message_presenter = double(execute: 'some message')

        expect(slack_gateway).to receive(:execute).with(
          channel: 'govuk-developers',
          message: 'some message'
        )

        described_class.new(
          slack_gateway: slack_gateway,
          team_gateway: team_gateway,
          pull_request_gateway: pull_request_gateway,
          message_presenter: message_presenter
        ).execute
      end
    end
  end
end
