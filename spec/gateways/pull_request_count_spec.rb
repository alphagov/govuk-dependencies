describe Gateways::PullRequestCount do
  context 'when getting all PRs for dependabot' do
    before do
      stub_request(:get, "https://api.github.com/search/issues?q=is:pr%20user:alphagov%20author:app/dependabot-preview")
        .to_return(body: File.open('spec/fixtures/pull_requests.json'), headers: { 'Content-Type' => 'application/json' })
    end
    it 'returns the total count' do
      count = described_class.new.execute
      expect(count).to eq(4)
    end
  end
end
