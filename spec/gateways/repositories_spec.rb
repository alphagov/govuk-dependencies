describe Gateways::Repositories do
  around do |example|
    ClimateControl.modify GITHUB_TOKEN: "some_token" do
      VCR.use_cassette("repositories") do
        example.run
      end
    end
  end

  context "with the alphagov organisation" do
    let(:repos) do
      subject.execute.map(&:name)
    end

    it "returns only those with a govuk topic" do
      expect(repos).to include("whitehall", "publishing-api")
      expect(repos).not_to include("govwifi-admin")
    end
  end
end
