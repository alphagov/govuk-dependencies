describe Gateways::Team do
  context "Given no teams" do
    before do
      stub_request(:get, "https://docs.publishing.service.gov.uk/repos.json")
        .to_return(body: "[]", headers: { "Content-Type" => "application/json" })
    end

    it "returns an empty list" do
      result = described_class.new.execute
      expect(result).to be_empty
    end
  end

  context "with no team set and one application" do
    before do
      stub_request(:get, "https://docs.publishing.service.gov.uk/repos.json")
        .to_return(
          body: File.read("spec/fixtures/application_with_no_team.json"),
          headers: { "Content-Type" => "application/json" },
        )
    end

    it "returns the apps with the default team" do
      result = described_class.new.execute
      expect(result.count).to eq(1)
      expect(result.first.team_name).to eq("govuk-developers")
      expect(result.first.applications).to eq(%w[asset-manager])
      expect(result.first.continuously_deployed_apps).to eq(%w[asset-manager])
    end
  end

  context "Given one team" do
    context "with one application" do
      before do
        stub_request(:get, "https://docs.publishing.service.gov.uk/repos.json")
          .to_return(
            body: File.read("spec/fixtures/team_with_one_application.json"),
            headers: { "Content-Type" => "application/json" },
          )
      end

      it "Returns a list one team object" do
        result = described_class.new.execute
        expect(result.count).to eq(1)
        expect(result.first.team_name).to eq("govuk-pub-workflow")
        expect(result.first.applications).to eq(%w[asset-manager])
        expect(result.first.continuously_deployed_apps).to eq(%w[asset-manager])
      end
    end

    context "with two applications" do
      before do
        stub_request(:get, "https://docs.publishing.service.gov.uk/repos.json")
          .to_return(
            body: File.read("spec/fixtures/team_with_two_applications.json"),
            headers: { "Content-Type" => "application/json" },
          )
      end

      it "Returns a list of two team objects" do
        result = described_class.new.execute
        expect(result.count).to eq(1)
        expect(result.first.team_name).to eq("govuk-platform-health")
        expect(result.first.applications).to eq(%w[asset-manager asset-uploader])
        expect(result.first.continuously_deployed_apps).to eq(%w[asset-manager])
      end
    end
  end

  context "with two teams and multiple applications" do
    before do
      stub_request(:get, "https://docs.publishing.service.gov.uk/repos.json")
      .to_return(
        body: File.read("spec/fixtures/multiple_teams_with_multiple_applications.json"),
        headers: { "Content-Type" => "application/json" },
      )
    end

    it "Returns a list of team objects with their respective applications" do
      result = described_class.new.execute

      expect(result.count).to eq(2)
      expect(result.first.team_name).to eq("govuk-platform-health")
      expect(result.first.applications).to eq(%w[publisher frontend])
      expect(result.first.continuously_deployed_apps).to eq([])

      expect(result.last.team_name).to eq("govuk-searchandnav")
      expect(result.last.applications).to eq(%w[government-frontend])
      expect(result.last.continuously_deployed_apps).to eq(%w[government-frontend])
    end
  end
end
