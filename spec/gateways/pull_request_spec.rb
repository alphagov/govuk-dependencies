describe Gateways::PullRequest do
  context 'No open pull requests from Dependabot' do
    before do
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot')
        .with(headers: { 'Authorization' => 'token some_token' })
        .to_return(
          body: '{ "total_count": 0, "incomplete_results": false, "items": [] }',
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'Returns an empty array' do
      ENV['GITHUB_TOKEN'] = 'some_token'
      expect(described_class.new.execute).to be_empty
    end
  end

  context 'There are open pull requests from Dependabot' do
    before do
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot')
        .with(headers: { 'Authorization' => 'token some_token' })
        .to_return(
          body: File.read('spec/fixtures/pull_requests.json'),
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'Returns a list of pull requests' do
      Timecop.freeze(Date.parse('2018-01-25')) do
        ENV['GITHUB_TOKEN'] = 'some_token'
        result = described_class.new.execute

        expect(result.count).to eq(3)
        expect(result[0].title).to eq('Bump gds-sso from 13.5.0 to 13.5.1')
        expect(result[0].application_name).to eq('publisher')
        expect(result[0].url).to eq('https://github.com/alphagov/publisher/pull/761')
        expect(result[0].open_since).to eq('yesterday')

        expect(result[1].title).to eq('Bump gds-sso from 13.5.0 to 13.5.1')
        expect(result[1].application_name).to eq('frontend')
        expect(result[1].url).to eq('https://github.com/alphagov/frontend/pull/1146')
        expect(result[1].open_since).to eq('yesterday')
      end
    end
  end
end
