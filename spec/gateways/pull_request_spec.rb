describe Gateways::PullRequest do
  context 'No open pull requests from Dependabot' do
    before do
      stub_request(:get, 'https://api.github.com/search/issues?q=is:pr+user:alphagov+state:open+author:app/dependabot')
        .to_return(
          body: '{ "total_count": 0, "incomplete_results": false, "items": [] }',
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'Returns an empty array' do
      expect(described_class.new.execute).to be_empty
    end
  end

  context 'There are open pull requests from Dependabot' do
    before do
      stub_request(:get, 'https://api.github.com/search/issues?q=is:pr+user:alphagov+state:open+author:app/dependabot')
        .to_return(
          body: File.read('spec/fixtures/pull_requests.json'),
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'Returns a list of pull requests' do
      result = described_class.new.execute

      expect(result.count).to eq(3)
      expect(result[0].title).to eq('Bump gds-sso from 13.5.0 to 13.5.1')
      expect(result[0].application_name).to eq('publisher')
      expect(result[0].url).to eq('https://api.github.com/repos/alphagov/publisher/issues/761')
      expect(result[0].opened_at).to eq(Date.parse('2018-01-24'))

      expect(result[1].title).to eq('Bump gds-sso from 13.5.0 to 13.5.1')
      expect(result[1].application_name).to eq('frontend')
      expect(result[1].url).to eq('https://api.github.com/repos/alphagov/frontend/issues/1146')
      expect(result[1].opened_at).to eq(Date.parse('2018-01-24'))
    end
  end
end
