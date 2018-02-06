describe Presenters::Slack::FullMessage do
  context 'Given a single pull request' do
    it 'formats the message' do
      team_name = 'email'
      pull_requests = [
        {
          application_name: 'content-tagger',
          title: 'Bump Rspec from 4.1 to 5.1',
          opened_at: Date.today,
          url: 'https://github.com/alphagov/frontend/pulls/123'
        }
      ]

      result = described_class.new.execute(pull_requests: pull_requests, team_name: team_name)

      expect(result).to eq('#email You have 1 Dependabot PRs open on the following apps:

content-tagger https://github.com/alphagov/content-tagger/pulls/app/dependabot

Feedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback')
    end
  end

  context 'Given multiple pull requests' do
    it 'formats the message' do
      team_name = 'taxonomy'
      pull_requests = [
        { application_name: 'collections-publisher',
          title: 'Bump Rails from 4.2 to 5.0',
          opened_at: Date.today,
          url: 'https://github.com/alphagov/frontend/pulls/123' }, {
          application_name: 'content-tagger',
          title: 'Bump Rspec from 4.1 to 5.1',
          opened_at: Date.today,
          url: 'https://github.com/alphagov/frontend/pulls/123'
        }
      ]

      result = described_class.new.execute(pull_requests: pull_requests, team_name: team_name)

      expect(result).to eq('#taxonomy You have 2 Dependabot PRs open on the following apps:

collections-publisher https://github.com/alphagov/collections-publisher/pulls/app/dependabot
content-tagger https://github.com/alphagov/content-tagger/pulls/app/dependabot

Feedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback')
    end

    it 'groups by application' do
      team_name = 'taxonomy'
      pull_requests = [
        { application_name: 'collections-publisher',
          title: 'Bump Rails from 4.2 to 5.0',
          opened_at: Date.today,
          url: 'https://github.com/alphagov/frontend/pulls/123' }, {
          application_name: 'content-tagger',
          title: 'Bump Rspec from 4.1 to 5.1',
          opened_at: Date.today,
          url: 'https://github.com/alphagov/frontend/pulls/123'
        }, {
          application_name: 'content-tagger',
          title: 'Bump Rubocop from 1 to 2',
          opened_at: Date.today,
          url: 'https://github.com/alphagov/frontend/pulls/123'
        }
      ]

      result = described_class.new.execute(pull_requests: pull_requests, team_name: team_name)

      expect(result).to eq('#taxonomy You have 3 Dependabot PRs open on the following apps:

collections-publisher https://github.com/alphagov/collections-publisher/pulls/app/dependabot
content-tagger https://github.com/alphagov/content-tagger/pulls/app/dependabot

Feedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback')
    end
  end
end
