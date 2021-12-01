describe Gateways::Repositories do
  around do |example|
    ClimateControl.modify GITHUB_TOKEN: "some_token" do
      VCR.use_cassette("repositories") do
        example.run
      end
    end
  end

  context "with the alphagov organisation" do
    let(:baseurl) { "https://api.github.com/repos/alphagov" }
    let(:whitehall) { "#{baseurl}/whitehall" }
    let(:publishing_api) { "#{baseurl}/publishing-api" }
    let(:govwifi_admin) { "#{baseurl}/govwifi-admin" }

    it "returns only those with a govuk topic" do
      expect(subject.govuk_repo_urls).to include(whitehall, publishing_api)
      expect(subject.govuk_repo_urls).not_to include(govwifi_admin)
    end
  end
end
