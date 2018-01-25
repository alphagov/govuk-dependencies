describe Presenters::PullRequestsByApplication do
  context 'Given no pull requests' do
    it 'returns an empty array' do
      expect(described_class.new.execute([])).to eq([])
    end
  end

  context 'Given a single pull request' do
    it 'groups the pull request by the application name' do
      pull_request = Domain::PullRequest.new(
        application_name: 'frontend',
        title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
        url: 'https://www.github.com/alphagov/frontend/pull/123',
        opened_at: Date.parse('2018-01-01 08:00:00')
      )

      result = described_class.new.execute([pull_request])
      expect(result).to eq([
        {
          application_name: 'frontend',
          application_url: 'https://github.com/alphagov/frontend/pulls',
          pull_requests: [pull_request]
        }
      ])
    end
  end

  context 'Given multiple pull requests for a single repo' do
    it 'groups the pull requests by the application name' do
      pull_requests = [
        Domain::PullRequest.new(
          application_name: 'frontend',
          title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
          url: 'https://www.github.com/alphagov/frontend/pull/123',
          opened_at: Date.parse('2018-01-01 08:00:00')
        ),
        Domain::PullRequest.new(
          application_name: 'frontend',
          title: 'Bump uglifier from 4.5.6 to 7.8.9',
          url: 'https://www.github.com/alphagov/frontend/pull/456',
          opened_at: Date.parse('2018-01-01 08:00:00')
        )
      ]
      result = described_class.new.execute(pull_requests)
      expect(result).to eq(
        [
          {
            application_name: 'frontend',
            application_url: 'https://github.com/alphagov/frontend/pulls',
            pull_requests: pull_requests
          }
        ]
      )
    end
  end

  context 'Given pull requests for multiple applications' do
    it 'groups the pull requests by the application name' do
      frontend_pull_request = Domain::PullRequest.new(
        application_name: 'frontend',
        title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
        url: 'https://www.github.com/alphagov/frontend/pull/123',
        opened_at: Date.parse('2018-01-01 08:00:00')
      )

      publisher_pull_request = Domain::PullRequest.new(
        application_name: 'publisher',
        title: 'Bump uglifier from 4.5.6 to 7.8.9',
        url: 'https://www.github.com/alphagov/frontend/pull/456',
        opened_at: Date.parse('2018-01-01 08:00:00')
      )

      publisher_pull_request2 = Domain::PullRequest.new(
        application_name: 'publisher',
        title: 'Bump uglifier from 4.5.6 to 7.8.9',
        url: 'https://www.github.com/alphagov/frontend/pull/456',
        opened_at: Date.parse('2018-01-01 08:00:00')
      )

      result = described_class.new.execute(
        [
          frontend_pull_request,
          publisher_pull_request,
          publisher_pull_request2
        ]
      )

      expect(result).to eq([
        {
          application_name: 'frontend',
          application_url: 'https://github.com/alphagov/frontend/pulls',
          pull_requests: [frontend_pull_request]
        },
        {
          application_name: 'publisher',
          application_url: 'https://github.com/alphagov/publisher/pulls',
          pull_requests: [publisher_pull_request, publisher_pull_request2]
        }
      ])
    end
  end
end
