describe UseCases::SplitSummarisedPullRequests do
  context 'with a pull request which bumps two gems' do
    it 'returns two pull request hashes' do
      pull_request = {
        application_name: 'frontend',
        title: 'Bump Rails and gds-api-adapters',
        open_since: 'today',
        url: 'https://github.com/alphagov/frontend/pulls/123'
      }

      result = described_class.new.execute(pull_request: pull_request)

      expect(result).to eq([{
        application_name: 'frontend',
        title: 'Bump Rails',
        url: 'https://github.com/alphagov/frontend/pulls/123',
        open_since: 'today'
      }, {
        application_name: 'frontend',
        title: 'Bump gds-api-adapters',
        url: 'https://github.com/alphagov/frontend/pulls/123',
        open_since: 'today'
      }])
    end
  end

  context 'with a pull request which bumps three gems' do
    it 'returns three pull request hashes' do
      pull_request = {
        application_name: 'frontend',
        title: 'Bump Rails, Rspec and gds-api-adapters',
        open_since: 'today',
        url: 'https://github.com/alphagov/frontend/pulls/123'
      }

      result = described_class.new.execute(pull_request: pull_request)

      expect(result).to eq([{
        application_name: 'frontend',
        title: 'Bump Rails',
        url: 'https://github.com/alphagov/frontend/pulls/123',
        open_since: 'today'
      }, {
        application_name: 'frontend',
        title: 'Bump Rspec',
        url: 'https://github.com/alphagov/frontend/pulls/123',
        open_since: 'today'
      }, {
        application_name: 'frontend',
        title: 'Bump gds-api-adapters',
        url: 'https://github.com/alphagov/frontend/pulls/123',
        open_since: 'today'
      }])
    end
  end
end
