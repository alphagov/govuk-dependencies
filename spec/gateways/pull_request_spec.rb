describe Gateways::PullRequest do
  include StubHelpers
  around do |example|
    ClimateControl.modify GITHUB_TOKEN: "some_token" do
      VCR.use_cassette("repositories") do
        example.run
      end
    end
  end

  context "No open pull requests from Dependabot" do
    before do
      stub_github_request(review_required_url, no_pull_requests_body)
      stub_github_request(approved_url, no_pull_requests_body)
      stub_github_request(changes_requested_url, no_pull_requests_body)
    end

    it "Returns an empty array" do
      expect(described_class.new.execute).to be_empty
    end
  end

  context "There are open approved pull requests from Dependabot" do
    before do
      stub_github_request(approved_url, pull_requests_body)
      stub_github_request(review_required_url, no_pull_requests_body)
      stub_github_request(changes_requested_url, no_pull_requests_body)
    end

    it "Returns a list of pull requests" do
      Timecop.freeze(Date.parse("2018-01-25")) do
        result = described_class.new.execute

        expect(result.count).to eq(3)

        expect(result[0].title).to eq("Bump gds-sso from 13.5.0 to 13.5.1")
        expect(result[0].application_name).to eq("publisher")
        expect(result[0].url).to eq("https://github.com/alphagov/publisher/pull/761")
        expect(result[0].status).to eq("approved")
        expect(result[0].opened_at).to eq(Date.parse("2018-01-25"))
        expect(result[0].open_since).to eq("today")

        expect(result[1].title).to eq("Bump gds-sso from 13.5.0 to 13.5.1")
        expect(result[1].application_name).to eq("frontend")
        expect(result[1].url).to eq("https://github.com/alphagov/frontend/pull/1146")
        expect(result[1].status).to eq("approved")
        expect(result[1].opened_at).to eq(Date.parse("2018-01-24"))
        expect(result[1].open_since).to eq("yesterday")
      end
    end
  end

  context "There are open pull requests that require review" do
    context "there are less than 100 results" do
      before do
        stub_github_request(approved_url, no_pull_requests_body)
        stub_github_request(review_required_url, pull_requests_body)
        stub_github_request(changes_requested_url, no_pull_requests_body)
      end

      it 'Sets the status on the Pull request to "review required"' do
        result = described_class.new.execute
        expect(result.first.status).to eq("review required")
        expect(result.count).to eq(3)
      end
    end

    context "there are more than 100 results" do
      before do
        stub_github_request(approved_url, no_pull_requests_body)
        VCR.insert_cassette("review_required_pull_requests")
        stub_github_request(changes_requested_url, no_pull_requests_body)
      end

      it 'Sets the status on the Pull request to "review required"' do
        result = described_class.new.execute
        expect(result.first.status).to eq("review required")
        expect(result.count).to eq(165)
      end
      after do
        VCR.eject_cassette("review_required_pull_requests")
      end
    end
  end

  context "There are open pull requests that require changes" do
    before do
      stub_github_request(approved_url, no_pull_requests_body)
      stub_github_request(review_required_url, no_pull_requests_body)
      stub_github_request(changes_requested_url, pull_requests_body)
    end

    it 'Sets the status on the Pull request to "review required"' do
      result = described_class.new.execute

      expect(result.first.status).to eq("changes requested")
    end
  end
end
