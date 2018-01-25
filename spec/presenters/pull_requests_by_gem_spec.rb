describe Presenters::PullRequestByGem do
  context 'Given no pull requests' do
    it 'returns an empty array' do
      expect(described_class.new.execute([])).to eq([])
    end
  end

  context 'Given a single pull request' do
    it 'groups the pull request by the gem name' do
      pull_request = Domain::PullRequest.new(
        application_name: 'frontend',
        title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
        url: 'https://www.github.com/alphagov/frontend/pull/123',
        opened_at: Date.parse('2018-01-01 08:00:00')
      )

      result = described_class.new.execute([pull_request])
      expect(result).to eq([
        {
          gem_name: 'gds-api-adapters',
          pull_requests: [
            {
              application_name: 'frontend',
              version: '4.5.6',
              url: 'https://www.github.com/alphagov/frontend/pull/123'
            }
          ]
        }
      ])
    end
  end

  context 'Given multiple pull requests for a single gem' do
    it 'groups the pull requests by the gem name' do
      pull_requests = [
        Domain::PullRequest.new(
          application_name: 'frontend',
          title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
          url: 'https://www.github.com/alphagov/frontend/pull/123',
          opened_at: Date.parse('2018-01-01 08:00:00')
        ),
        Domain::PullRequest.new(
          application_name: 'signon',
          title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
          url: 'https://www.github.com/alphagov/frontend/pull/456',
          opened_at: Date.parse('2018-01-01 08:00:00')
        )
      ]
      result = described_class.new.execute(pull_requests)
      expect(result).to eq([
        {
          gem_name: 'gds-api-adapters',
          pull_requests: [
            {
              application_name: 'frontend',
              version: '4.5.6',
              url: 'https://www.github.com/alphagov/frontend/pull/123'
            },
            {
              application_name: 'signon',
              version: '4.5.6',
              url: 'https://www.github.com/alphagov/frontend/pull/456'
            }
          ]
        }
      ])
    end
  end

  context 'Given pull requests for multiple gems' do
    it 'groups the pull requests by the gem' do
      gds_api_adapters_pull_request = Domain::PullRequest.new(
        application_name: 'frontend',
        title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
        url: 'https://www.github.com/alphagov/frontend/pull/123',
        opened_at: Date.parse('2018-01-01 08:00:00')
      )

      gds_api_adapters_pull_request2 = Domain::PullRequest.new(
        application_name: 'publisher',
        title: 'Bump gds-api-adapters from 4.5.6 to 7.8.9',
        url: 'https://www.github.com/alphagov/frontend/pull/456',
        opened_at: Date.parse('2018-01-01 08:00:00')
      )

      uglifier_pull_request = Domain::PullRequest.new(
        application_name: 'publisher',
        title: 'Bump uglifier from 4.5.6 to 7.8.9',
        url: 'https://www.github.com/alphagov/publisher/pull/456',
        opened_at: Date.parse('2018-01-01 08:00:00')
      )

      result = described_class.new.execute(
        [
          gds_api_adapters_pull_request,
          gds_api_adapters_pull_request2,
          uglifier_pull_request
        ]
      )

      expect(result).to eq([
        {
          gem_name: 'gds-api-adapters',
          pull_requests: [
            {
              application_name: 'frontend',
              version: '4.5.6',
              url: 'https://www.github.com/alphagov/frontend/pull/123',
            },
            {
              application_name: 'publisher',
              version: '7.8.9',
              url: 'https://www.github.com/alphagov/frontend/pull/456',
            },
          ]
        }, {
          gem_name: 'uglifier',
          pull_requests: [
            {
              application_name: 'publisher',
              version: '7.8.9',
              url: 'https://www.github.com/alphagov/publisher/pull/456',
            }
          ]
        }
      ])
    end
  end
end
