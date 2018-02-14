describe UseCases::Slack::SendMessages do
  context 'given no teams or pull requests' do
    it 'does not call the slack gateway' do
      team_usecase = double(execute: [])
      pull_request_usecase = double(execute: [])
      slack_gateway = double
      message_presenter = double
      scheduler = double(should_send_message?: true)
      expect(slack_gateway).not_to receive(:execute)
      described_class.new(
        slack_gateway: slack_gateway,
        team_usecase: team_usecase,
        pull_request_usecase: pull_request_usecase,
        message_presenter: message_presenter,
        scheduler: scheduler
      ).execute
    end
  end

  context 'given one team' do
    context 'and no pull requests' do
      it 'does not call the slack gateway' do
        team_usecase = double(execute: [
          {
            team_name: 'email',
            applications: ['whitehall']
          }
        ])
        pull_request_usecase = double(execute: [])
        slack_gateway = double
        message_presenter = double
        expect(slack_gateway).not_to receive(:execute)
        described_class.new(
          slack_gateway: slack_gateway,
          team_usecase: team_usecase,
          pull_request_usecase: pull_request_usecase,
          message_presenter: message_presenter
        ).execute
      end
    end

    context 'and one pull request' do
      it 'sends a single message with one pull request open' do
        team_usecase = double(execute: [
          {
            team_name: 'email',
            applications: ['whitehall']
          }
        ])
        pull_request_usecase = double(execute: [
          {
            application_name: 'whitehall',
            title: 'Bump foo 1.2.3 to 4.5.6',
            status: 'approved',
            open_since: 'yesterday',
            url: 'https://github.com/alphagov/whitehall/123'
          }
        ])
        slack_gateway = double
        message_presenter = double(execute: 'some message')

        expect(slack_gateway).to receive(:execute).with(channel: 'email', message: 'some message')

        described_class.new(
          slack_gateway: slack_gateway,
          team_usecase: team_usecase,
          pull_request_usecase: pull_request_usecase,
          message_presenter: message_presenter
        ).execute
      end
    end

    context 'multiple pull requests for one team' do
      it 'sends a single message' do
        team_usecase = double(execute: [
          {
            team_name: 'email',
            applications: ['whitehall']
          }
        ])
        pull_request_usecase = double(execute: [
          {
            application_name: 'whitehall',
            title: 'Bump foo 1.2.3 to 4.5.6',
            status: 'approved',
            open_since: 'yesterday',
            url: 'https://github.com/alphagov/whitehall/123'
          }, {
            application_name: 'whitehall',
            title: 'Bump Rails from 4.2.1 to 5.1.0',
            status: 'approved',
            open_since: 'today',
            url: 'https://github.com/alphagov/whitehall/123'
          }
        ])
        slack_gateway = double
        message_presenter = double(execute: 'some message')
        expect(slack_gateway).to receive(:execute).with(
          channel: 'email',
          message: 'some message'
        )
        described_class.new(
          slack_gateway: slack_gateway,
          team_usecase: team_usecase,
          pull_request_usecase: pull_request_usecase,
          message_presenter: message_presenter
        ).execute
      end
    end
  end

  context 'multiple pull requests for multiple teams' do
    it 'sends one message to each team' do
      team_usecase = double(execute: [
        {
          team_name: 'email',
          applications: ['whitehall']
        }, {
          team_name: 'platform_support',
          applications: ['travel-advice-publisher']
        }
      ])

      pull_request_usecase = double(execute: [
        {
          application_name: 'whitehall',
          title: 'Bump foo 1.2.3 to 4.5.6',
          status: 'approved',
          open_since: 'yesterday',
          url: 'https://github.com/alphagov/whitehall/123'
        }, {
          application_name: 'whitehall',
          title: 'Bump Rails from 4.2.1 to 5.1.0',
          status: 'approved',
          open_since: 'yesterday',
          url: 'https://github.com/alphagov/whitehall/457'
        }, {
          application_name: 'travel-advice-publisher',
          title: 'Bump Rails from 1.3.4 to 2.0.0',
          status: 'approved',
          open_since: 'yesterday',
          url: 'https://github.com/alphagov/travel-advice-publisher/123'
        }
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
        team_usecase: team_usecase,
        pull_request_usecase: pull_request_usecase,
        message_presenter: message_presenter
      ).execute
    end
  end

  context 'given pull requests which have no team' do
    context 'with no other pull requests' do
      it 'sends a message to govuk-developers' do
        team_usecase = double(execute: [
          {
            team_name: 'non_existent_team',
            applications: ['travel-advice-publisher']
          }
        ])
        pull_request_usecase = double(execute: [
          {
            application_name: 'whitehall',
            title: 'Bump foo 1.2.3 to 4.5.6',
            status: 'approved',
            opened_at: 'yesterday',
            url: 'https://github.com/alphagov/whitehall/123'
          }
        ])
        slack_gateway = double
        message_presenter = double(execute: 'some message')

        expect(slack_gateway).to receive(:execute).with(
          channel: 'govuk-developers',
          message: 'some message'
        )

        described_class.new(
          slack_gateway: slack_gateway,
          team_usecase: team_usecase,
          pull_request_usecase: pull_request_usecase,
          message_presenter: message_presenter
        ).execute
      end
    end
  end

  context 'Given a request for only one team' do
    it 'filters results to just that team' do
      some_team = {
        team_name: 'some-team',
        applications: ['some-application']
      }
      some_other_team = {
        team_name: 'some-other-team',
        applications: ['some-other-application']
      }

      team_usecase = double(execute: [some_team, some_other_team])
      pull_request_usecase = double(execute: [
        {
          application_name: 'some-application',
          title: 'Bump foo 1.2.3 to 4.5.6',
          opened_at: 'yesterday',
          url: 'https://github.com/alphagov/whitehall/123'
        }, {
          application_name: 'some-other-application',
          title: 'Bump foo 1.2.3 to 4.5.6',
          open_since: 'yesterday',
          url: 'https://github.com/alphagov/whitehall/123'
        }
      ])
      slack_gateway = double
      message_presenter = double(execute: 'some message')

      expect(slack_gateway).to receive(:execute).with(channel: 'some-team', message: 'some message')
      expect(slack_gateway).to_not receive(:execute).with(channel: 'some-other-team', message: 'some message')

      described_class.new(
        slack_gateway: slack_gateway,
        team_usecase: team_usecase,
        pull_request_usecase: pull_request_usecase,
        message_presenter: message_presenter
      ).execute(team: 'some-team')
    end
  end

  context 'Given it is out of schedule' do
    it 'does not send messages' do
      scheduler = double(should_send_message?: false)
      message_presenter = double(execute: 'some message')
      slack_gateway = double

      expect(slack_gateway).to_not receive(:execute)

      described_class.new(
        scheduler: scheduler,
        message_presenter: message_presenter
      ).execute
    end
  end

  context 'Given it is in schedule' do
    it 'sends a messages' do
      scheduler = double(should_send_message?: true)
      message_presenter = double(execute: 'some message')
      slack_gateway = double
      pull_request_usecase = double(execute: [double.as_null_object])
      team_usecase = double(execute: [])

      expect(slack_gateway).to receive(:execute)

      described_class.new(
        scheduler: scheduler,
        message_presenter: message_presenter,
        slack_gateway: slack_gateway,
        pull_request_usecase: pull_request_usecase,
        team_usecase: team_usecase
      ).execute
    end
  end
end
