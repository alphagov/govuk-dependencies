require 'date'

describe UseCases::FetchPullRequests do
  let(:gateway) { double(execute: pull_requests) }
  let(:results) { described_class.new(gateway: gateway).execute }

  context 'Given no open pull requests' do
    let(:pull_requests) { [] }

    it 'Returns an empty array given no pull requests' do
      expect(results).to be_empty
    end
  end

  context 'Given a single open pull request' do
    let(:pull_request) do
      Domain::PullRequest.new(
        application_name: 'frontend',
        title: 'Bump gds-api-adapters from 1.2.3 to 4.5.6',
        url: 'https://www.github.com/alphagov/frontend/pull/123',
        opened_at: Date.parse('2018-01-01 08:00:00')
      )
    end
    let(:pull_requests) { [pull_request] }

    it 'Returns a single pull request' do
      expect(results.count).to eq(1)
      expect(results).to include(pull_request)
    end
  end
end
