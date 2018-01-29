describe Gateways::Team do
  context 'Given no teams' do
    before do
      stub_request(:get, "https://docs.publishing.service.gov.uk/apps.json")
        .to_return(body: "[]", headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns an empty list' do
      result = described_class.new.execute
      expect(result).to be_empty
    end
  end

  context 'Given one team' do
    context 'with one application' do
      before do
        stub_request(:get, "https://docs.publishing.service.gov.uk/apps.json")
          .to_return(
            body: File.read('spec/fixtures/team_with_one_application.json'),
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'Returns a list one team object' do
        result = described_class.new.execute
        expect(result.count).to eq(1)
        expect(result.first.team_name).to eq('#asset-management')
        expect(result.first.applications).to eq(['asset-manager'])
      end
    end

    context 'with two applications' do
      before do
        stub_request(:get, "https://docs.publishing.service.gov.uk/apps.json")
          .to_return(
            body: File.read('spec/fixtures/team_with_two_applications.json'),
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'Returns a list of two team objects' do
        result = described_class.new.execute
        expect(result.count).to eq(1)
        expect(result.first.team_name).to eq('#asset-management')
        expect(result.first.applications).to eq(['asset-manager', 'asset-uploader'])
      end
    end
  end

  context 'with two teams and multiple applications' do
    before do
      stub_request(:get, "https://docs.publishing.service.gov.uk/apps.json")
      .to_return(
        body: File.read('spec/fixtures/multiple_teams_with_multiple_applications.json'),
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    it 'Returns a list of team objects with their respective applications' do
      result = described_class.new.execute

      expect(result.count).to eq(2)
      expect(result.first.team_name).to eq('#modelling-services')
      expect(result.first.applications).to eq(['publisher'])

      expect(result.last.team_name).to eq('#start-pages')
      expect(result.last.applications).to eq(['frontend', 'government-frontend'])
    end
  end
end
