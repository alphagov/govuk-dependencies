describe Presenters::Slack::FullMessage do
  context 'Given a single pull request' do
    it 'formats the message' do
      applications_by_team = {
        team_name: 'email',
        applications: [
          {
            application_name: 'content-tagger',
            application_url: 'https://github.com/alphagov/content-tagger/app/dependabot',
            pull_request_count: 1
          }
        ]
      }

      result = described_class.new.execute(applications_by_team: applications_by_team)

      expect(result).to eq('#email You have 1 Dependabot PRs open on the following apps:

content-tagger https://github.com/alphagov/content-tagger/pulls/app/dependabot

Feedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback')
    end
  end

  context 'Given multiple pull requests' do
    it 'formats the message' do
      applications_by_team = {
        team_name: 'taxonomy',
        applications: [
          {
            application_name: 'collections-publisher',
            application_url: 'https://github.com/alphagov/content-publisher/app/dependabot',
            pull_request_count: 1
          }, {
            application_name: 'content-tagger',
            application_url: 'https://github.com/alphagov/content-tagger/app/dependabot',
            pull_request_count: 1
          }
        ]
      }

      result = described_class.new.execute(applications_by_team: applications_by_team)

      expect(result).to eq('#taxonomy You have 2 Dependabot PRs open on the following apps:

collections-publisher https://github.com/alphagov/collections-publisher/pulls/app/dependabot
content-tagger https://github.com/alphagov/content-tagger/pulls/app/dependabot

Feedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback')
    end

    it 'groups by application' do
      applications_by_team = {
        team_name: 'taxonomy',
        applications: [
          {
            application_name: 'collections-publisher',
            application_url: 'https://github.com/alphagov/content-publisher/app/dependabot',
            pull_request_count: 1
          }, {
            application_name: 'content-tagger',
            application_url: 'https://github.com/alphagov/content-tagger/app/dependabot',
            pull_request_count: 2
          }
        ]
      }

      result = described_class.new.execute(applications_by_team: applications_by_team)

      expect(result).to eq('#taxonomy You have 3 Dependabot PRs open on the following apps:

collections-publisher https://github.com/alphagov/collections-publisher/pulls/app/dependabot
content-tagger https://github.com/alphagov/content-tagger/pulls/app/dependabot

Feedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback')
    end
  end
end
