describe Presenters::PullRequestsByTeam do
  context 'Given no pull requests' do
    context 'and no teams' do
      it 'returns an empty array' do
        expect(described_class.new.execute(teams: [], ungrouped_pull_requests: [])).to eq([])
      end
    end

    context 'and some teams' do
      it 'returns an empty array' do
        teams = [
          Domain::Team.new(team_name: '#team-one', applications: ['application-one']),
          Domain::Team.new(team_name: '#team-two', applications: ['application-two'])
        ]
        expect(described_class.new.execute(teams: teams, ungrouped_pull_requests: [])).to eq([])
      end
    end
  end

  context 'Given one pull request' do
    context 'and one team that the pull request belongs to' do
      it 'returns an array of applications grouped by team' do
        team = Domain::Team.new(team_name: '#email', applications: ['signon'])
        pull_request = Domain::PullRequest.new(
          application_name: 'signon',
          title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
          url: 'https://www.github.com/alphagov/signon/pull/456',
          opened_at: Date.parse('2018-01-01 08:00:00')
        )
        expect(described_class.new.execute(
                 teams: [team],
                 ungrouped_pull_requests: [pull_request]
        )).to eq([
          {
            team_name: '#email',
            applications: [
              {
                application_name: 'signon',
                application_url: 'https://github.com/alphagov/signon/pulls/app/dependabot',
                pull_request_count: 1
              }
            ]
          }
        ])
      end
    end
  end

  context 'Given multiple pull requests' do
    context 'and one team that the pull requests belongs to' do
      it 'returns an array of applications grouped by team' do
        team = Domain::Team.new(team_name: '#email', applications: ['signon', 'email-alert-api'])
        pull_requests = [
          Domain::PullRequest.new(
            application_name: 'signon',
            title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
            url: 'https://www.github.com/alphagov/signon/pull/456',
            opened_at: Date.parse('2018-01-01 08:00:00')
          ),
          Domain::PullRequest.new(
            application_name: 'email-alert-api',
            title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
            url: 'https://www.github.com/alphagov/email-alert-api/pull/456',
            opened_at: Date.parse('2018-01-01 08:00:00')
        )
]
        expect(described_class.new.execute(
                 teams: [team],
                 ungrouped_pull_requests: pull_requests
        )).to eq([
          {
            team_name: '#email',
            applications: [
              {
                application_name: 'signon',
                application_url: 'https://github.com/alphagov/signon/pulls/app/dependabot',
                pull_request_count: 1
              }, {
                application_name: 'email-alert-api',
                application_url: 'https://github.com/alphagov/email-alert-api/pulls/app/dependabot',
                pull_request_count: 1
              }
            ]
          }
        ])
      end

      it 'counts the number of pull requests' do
        team = Domain::Team.new(team_name: '#email', applications: ['signon', 'email-alert-api'])
        pull_request = Domain::PullRequest.new(
          application_name: 'signon',
          title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
          url: 'https://www.github.com/alphagov/signon/pull/456',
          opened_at: Date.parse('2018-01-01 08:00:00')
        )
        pull_request2 = Domain::PullRequest.new(
          application_name: 'signon',
          title: 'Bump Rails from 4.2.1 to 5.1.2',
          url: 'https://www.github.com/alphagov/signon/pull/457',
          opened_at: Date.parse('2018-01-01 08:00:00')
        )
        expect(described_class.new.execute(
                 teams: [team],
                 ungrouped_pull_requests: [pull_request, pull_request2]
        )).to eq([
          {
            team_name: '#email',
            applications: [
              {
                application_name: 'signon',
                application_url: 'https://github.com/alphagov/signon/pulls/app/dependabot',
                pull_request_count: 2
              }
            ]
          }
        ])
      end
    end

    context 'and multiple teams that the pull requests belongs to' do
      it 'returns an array of applications grouped by team' do
        teams = [Domain::Team.new(team_name: '#email', applications: ['signon', 'email-alert-api']),
                 Domain::Team.new(team_name: '#asset-management', applications: ['asset-manager'])]

        pull_requests = [
          Domain::PullRequest.new(
            application_name: 'signon',
            title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
            url: 'https://www.github.com/alphagov/signon/pull/456',
            opened_at: Date.parse('2018-01-01 08:00:00')
          ),
          Domain::PullRequest.new(
            application_name: 'email-alert-api',
            title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
            url: 'https://www.github.com/alphagov/email-alert-api/pull/456',
            opened_at: Date.parse('2018-01-01 08:00:00')
          ),
          Domain::PullRequest.new(
            application_name: 'asset-manager',
            title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
            url: 'https://www.github.com/alphagov/email-alert-api/pull/456',
            opened_at: Date.parse('2018-01-01 08:00:00')
        )
]

        expect(described_class.new.execute(
                 teams: teams,
                 ungrouped_pull_requests: pull_requests
        )).to eq([
          {
            team_name: '#email',
            applications: [
              {
                application_name: 'signon',
                application_url: 'https://github.com/alphagov/signon/pulls/app/dependabot',
                pull_request_count: 1
              }, {
                application_name: 'email-alert-api',
                application_url: 'https://github.com/alphagov/email-alert-api/pulls/app/dependabot',
                pull_request_count: 1
              }
            ]
          }, {
            team_name: '#asset-management',
            applications: [
              {
                application_name: 'asset-manager',
                application_url: 'https://github.com/alphagov/asset-manager/pulls/app/dependabot',
                pull_request_count: 1
              }
            ]
          }
        ])
      end
    end
  end
end
