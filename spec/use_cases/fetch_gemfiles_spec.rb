describe UseCases::FetchGemfiles do
  context 'given no applications' do
    it 'does not fetch any gemfiles' do
      teams_use_case = double(execute: [])
      result = described_class.new(teams_use_case: teams_use_case).execute
      expect(result).to be_empty
    end
  end

  context 'given one application' do
    it 'fetches that Gemfile' do
      teams_use_case = double(execute: [
        {
          applications: ['foo-app']
        }
      ])

      gemfile_gateway = double(
        execute: Domain::Gemfile.new(file_contents: 'some contents')
      )

      result = described_class.new(
        gemfile_gateway: gemfile_gateway,
        teams_use_case: teams_use_case
      ).execute

      expect(result).to eq([
        {
          application_name: 'foo-app',
          gemfile_contents: 'some contents'
        }
      ])
    end
  end

  context 'given multiple application' do
    it 'fetches all the Gemfile' do
      teams_use_case = double(execute: [
        {
          applications: ['foo-app', 'bar-app']
        }
      ])

      gemfile_gateway = double
      allow(gemfile_gateway).to receive(:execute).with(application_name: 'foo-app').and_return(
        Domain::Gemfile.new(file_contents: 'foo app contents')
      )

      allow(gemfile_gateway).to receive(:execute).with(application_name: 'bar-app').and_return(
        Domain::Gemfile.new(file_contents: 'bar app contents')
      )

      result = described_class.new(gemfile_gateway: gemfile_gateway, teams_use_case: teams_use_case).execute

      expect(result).to eq([
        {
          application_name: 'foo-app',
          gemfile_contents: 'foo app contents'
        }, {
          application_name: 'bar-app',
          gemfile_contents: 'bar app contents'
        }
      ])
    end
  end

  context 'The gateway raised a GemfileNotFoundException' do
    it 'returns an empty result' do
      teams_use_case = double(execute: [{ applications: ['foo-app'] }])

      gemfile_gateway = double
      allow(gemfile_gateway).to receive(:execute).and_raise(GemfileNotFoundException)

      result = described_class.new(gemfile_gateway: gemfile_gateway, teams_use_case: teams_use_case).execute
      expect(result).to be_empty
    end
  end
end
