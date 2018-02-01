describe Presenters::PullRequestsByGem do
  context 'Given no pull requests' do
    it 'returns an empty array' do
      expect(described_class.new.execute([])).to eq([])
    end
  end

  context 'Given a single pull request' do
    it 'groups the pull request by the gem name' do
      pull_request = {
        application_name: 'frontend',
        title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
        url: 'https://www.github.com/alphagov/frontend/pull/123',
        opened_at: Date.parse('2018-01-01 08:00:00')
      }

      result = described_class.new.execute([pull_request])
      expect(result).to eq([
        {
          gem_name: 'gds-api-adapters',
          pull_requests: [pull_request]
        }
      ])
    end
  end

  context 'Given a split commit' do
    it 'Groups them correctly' do
      gds_api_adapter_pull_request = {
        application_name: 'frontend',
        title: 'Bump gds-api-adapters',
        url: 'https://www.github.com/alphagov/frontend/pull/123',
        opened_at: Date.parse('2018-01-01 08:00:00')
      }
      rspec_pull_request = {
        application_name: 'frontend',
        title: 'Bump rspec',
        url: 'https://www.github.com/alphagov/frontend/pull/123',
        opened_at: Date.parse('2018-01-01 08:00:00')
      }

      result = described_class.new.execute([gds_api_adapter_pull_request, rspec_pull_request])
      expect(result).to eq([
        {
          gem_name: 'gds-api-adapters',
          pull_requests: [gds_api_adapter_pull_request]
        }, {
          gem_name: 'rspec',
          pull_requests: [rspec_pull_request]
        }
      ])
    end
  end

  context 'Given multiple pull requests for a single gem' do
    it 'groups the pull requests by the gem name' do
      pull_requests = [
        {
          application_name: 'frontend',
          title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
          url: 'https://www.github.com/alphagov/frontend/pull/123',
          opened_at: Date.parse('2018-01-01 08:00:00')
        }, {
          application_name: 'signon',
          title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
          url: 'https://www.github.com/alphagov/signon/pull/456',
          opened_at: Date.parse('2018-01-01 08:00:00')
        }
      ]

      result = described_class.new.execute(pull_requests)
      expect(result).to eq([
        {
          gem_name: 'gds-api-adapters',
          pull_requests: pull_requests
        }
      ])
    end

    it 'orders the pull requests by application name' do
      signon_pull_request = {
        application_name: 'signon',
        title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
        url: 'https://www.github.com/alphagov/signon/pull/456',
        opened_at: Date.parse('2018-01-01 08:00:00')
      }

      frontend_pull_request = {
        application_name: 'frontend',
        title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
        url: 'https://www.github.com/alphagov/frontend/pull/123',
        opened_at: Date.parse('2018-01-01 08:00:00')
      }

      result = described_class.new.execute([signon_pull_request, frontend_pull_request])
      expect(result).to eq([
        {
          gem_name: 'gds-api-adapters',
          pull_requests: [frontend_pull_request, signon_pull_request]
        }
      ])
    end
  end

  context 'Given pull requests for multiple gems' do
    it 'groups the pull requests by the gem' do
      gds_api_adapters_pull_request = {
        application_name: 'frontend',
        title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
        url: 'https://www.github.com/alphagov/frontend/pull/123',
        opened_at: Date.parse('2018-01-01 08:00:00')
      }

      gds_api_adapters_pull_request2 = {
        application_name: 'publisher',
        title: 'Bump gds-api-adapters from 4.5.6 to 7.8.9',
        url: 'https://www.github.com/alphagov/frontend/pull/456',
        opened_at: Date.parse('2018-01-01 08:00:00')
      }

      uglifier_pull_request = {
        application_name: 'publisher',
        title: 'Bump uglifier from 4.5.6 to 7.8.9',
        url: 'https://www.github.com/alphagov/publisher/pull/456',
        opened_at: Date.parse('2018-01-01 08:00:00')
      }

      result = described_class.new.execute(
        [
          gds_api_adapters_pull_request2,
          gds_api_adapters_pull_request,
          uglifier_pull_request
        ]
      )

      expect(result).to eq([
        {
          gem_name: 'gds-api-adapters',
          pull_requests: [
            gds_api_adapters_pull_request,
            gds_api_adapters_pull_request2
          ]
        }, {
          gem_name: 'uglifier',
          pull_requests: [uglifier_pull_request]
        }
      ])
    end

    it 'orders the gems by name' do
      uglifier_pull_request = {
        application_name: 'publisher',
        title: 'Bump uglifier from 4.5.6 to 7.8.9',
        url: 'https://www.github.com/alphagov/publisher/pull/456',
        opened_at: Date.parse('2018-01-01 08:00:00')
      }

      gds_api_adapters_pull_request = {
        application_name: 'frontend',
        title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
        url: 'https://www.github.com/alphagov/frontend/pull/123',
        opened_at: Date.parse('2018-01-01 08:00:00')
      }

      gds_api_adapters_pull_request2 = {
        application_name: 'publisher',
        title: 'Bump gds-api-adapters from 4.5.6 to 7.8.9',
        url: 'https://www.github.com/alphagov/frontend/pull/456',
        opened_at: Date.parse('2018-01-01 08:00:00')
      }

      result = described_class.new.execute(
        [
          uglifier_pull_request,
          gds_api_adapters_pull_request2,
          gds_api_adapters_pull_request
        ]
      )

      expect(result).to eq([
        {
          gem_name: 'gds-api-adapters',
          pull_requests: [
            gds_api_adapters_pull_request,
            gds_api_adapters_pull_request2
          ]
        }, {
          gem_name: 'uglifier',
          pull_requests: [uglifier_pull_request]
        }
      ])
    end
  end
end
