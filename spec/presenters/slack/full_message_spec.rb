describe Presenters::Slack::FullMessage do
  context 'Given a single pull request' do
    it 'formats the message' do
      applications_by_team = {
        team_name: 'email',
        applications: [
          {
            application_name: 'content-tagger',
            application_url: 'https://github.com/alphagov/content-tagger/app/dependabot-preview',
            pull_request_count: 1
          }
        ]
      }

      result = described_class.new.execute(applications_by_team: applications_by_team)

      expect(result).to eq('<https://govuk-dependencies.herokuapp.com/team/email|email> have 1 Dependabot PRs open on the following apps:

<https://github.com/alphagov/content-tagger/pulls/app/dependabot-preview|content-tagger> (1)')
    end
  end

  context 'Given multiple pull requests' do
    it 'formats the message' do
      applications_by_team = {
        team_name: 'taxonomy',
        applications: [
          {
            application_name: 'collections-publisher',
            application_url: 'https://github.com/alphagov/content-publisher/app/dependabot-preview',
            pull_request_count: 1
          }, {
            application_name: 'content-tagger',
            application_url: 'https://github.com/alphagov/content-tagger/app/dependabot-preview',
            pull_request_count: 1
          }
        ]
      }

      result = described_class.new.execute(applications_by_team: applications_by_team)

      expect(result).to eq('<https://govuk-dependencies.herokuapp.com/team/taxonomy|taxonomy> have 2 Dependabot PRs open on the following apps:

<https://github.com/alphagov/collections-publisher/pulls/app/dependabot-preview|collections-publisher> (1) <https://github.com/alphagov/content-tagger/pulls/app/dependabot-preview|content-tagger> (1)')
    end

    it 'groups by application' do
      applications_by_team = {
        team_name: 'taxonomy',
        applications: [
          {
            application_name: 'collections-publisher',
            application_url: 'https://github.com/alphagov/content-publisher/app/dependabot-preview',
            pull_request_count: 1
          }, {
            application_name: 'content-tagger',
            application_url: 'https://github.com/alphagov/content-tagger/app/dependabot-preview',
            pull_request_count: 2
          }
        ]
      }

      result = described_class.new.execute(applications_by_team: applications_by_team)

      expect(result).to eq('<https://govuk-dependencies.herokuapp.com/team/taxonomy|taxonomy> have 3 Dependabot PRs open on the following apps:

<https://github.com/alphagov/collections-publisher/pulls/app/dependabot-preview|collections-publisher> (1) <https://github.com/alphagov/content-tagger/pulls/app/dependabot-preview|content-tagger> (2)')
    end
  end
end
