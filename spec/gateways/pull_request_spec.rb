describe Gateways::PullRequest do
  REVIEW_REQUIRED_URL = 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:required'.freeze
  APPROVED_URL = 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:approved'.freeze
  CHANGES_REQUESTED_URL = 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:changes_requested'.freeze
  NO_PULL_REQUESTS_BODY = '{ "total_count": 0, "incomplete_results": false, "items": [] }'.freeze

  around do |example|
    ClimateControl.modify GITHUB_TOKEN: "some_token" do
      VCR.use_cassette("repositories") do
        example.run
      end
    end
  end

  def stub_github_request(request_url, body)
    stub_request(:get, request_url)
      .with(headers: { 'Authorization' => 'token some_token' })
      .to_return(
        body: body,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  context 'No open pull requests from Dependabot' do
    before do
      stub_github_request(REVIEW_REQUIRED_URL, NO_PULL_REQUESTS_BODY)
      stub_github_request(APPROVED_URL, NO_PULL_REQUESTS_BODY)
      stub_github_request(CHANGES_REQUESTED_URL, NO_PULL_REQUESTS_BODY)
    end

    it 'Returns an empty array' do
      expect(described_class.new.execute).to be_empty
    end
  end

  context 'There are open approved pull requests from Dependabot' do
    before do
      stub_github_request(APPROVED_URL, File.read('spec/fixtures/pull_requests.json'))
      stub_github_request(REVIEW_REQUIRED_URL, NO_PULL_REQUESTS_BODY)
      stub_github_request(CHANGES_REQUESTED_URL, NO_PULL_REQUESTS_BODY)
    end

    it 'Returns a list of pull requests' do
      Timecop.freeze(Date.parse('2018-01-25')) do
        result = described_class.new.execute

        expect(result.count).to eq(3)

        expect(result[0].title).to eq('Bump gds-sso from 13.5.0 to 13.5.1')
        expect(result[0].application_name).to eq('publisher')
        expect(result[0].url).to eq('https://github.com/alphagov/publisher/pull/761')
        expect(result[0].status).to eq('approved')
        expect(result[0].opened_at).to eq(Date.parse('2018-01-24'))
        expect(result[0].open_since).to eq('yesterday')

        expect(result[1].title).to eq('Bump gds-sso from 13.5.0 to 13.5.1')
        expect(result[1].application_name).to eq('frontend')
        expect(result[1].url).to eq('https://github.com/alphagov/frontend/pull/1146')
        expect(result[1].status).to eq('approved')
        expect(result[1].opened_at).to eq(Date.parse('2018-01-24'))
        expect(result[1].open_since).to eq('yesterday')
      end
    end
  end

  context 'There are open pull requests that require review' do
    before do
      stub_github_request(APPROVED_URL, NO_PULL_REQUESTS_BODY)
      stub_github_request(REVIEW_REQUIRED_URL, File.read('spec/fixtures/pull_requests.json'))
      stub_github_request(CHANGES_REQUESTED_URL, NO_PULL_REQUESTS_BODY)
    end

    it 'Sets the status on the Pull request to "review required"' do
      result = described_class.new.execute

      expect(result.first.status).to eq('review required')
    end
  end

  context 'There are open pull requests that require changes' do
    before do
      stub_github_request(APPROVED_URL, NO_PULL_REQUESTS_BODY)
      stub_github_request(REVIEW_REQUIRED_URL, NO_PULL_REQUESTS_BODY)
      stub_github_request(CHANGES_REQUESTED_URL, File.read('spec/fixtures/pull_requests.json'))
    end

    it 'Sets the status on the Pull request to "review required"' do
      result = described_class.new.execute

      expect(result.first.status).to eq('changes requested')
    end
  end
end
