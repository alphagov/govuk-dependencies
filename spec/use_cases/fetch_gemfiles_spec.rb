describe UseCases::FetchGemfiles do
  context 'given no applications' do
    it 'does not fetch any gemfiles' do
      application_names = []
      result = described_class.new.execute(application_names: application_names)
      expect(result).to be_empty
    end
  end

  context 'given one application' do
    it 'fetches that Gemfile' do
      application_names = %w(foo-app)
      gemfile_gateway = double(
        execute: Domain::Gemfile.new(file_contents: 'some contents')
      )

      result = described_class.new(gemfile_gateway: gemfile_gateway)
        .execute(application_names: application_names)

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
      application_names = %w(foo-app bar-app)
      gemfile_gateway = double
      allow(gemfile_gateway).to receive(:execute).with(application_name: 'foo-app').and_return(
        Domain::Gemfile.new(file_contents: 'foo app contents')
      )

      allow(gemfile_gateway).to receive(:execute).with(application_name: 'bar-app').and_return(
        Domain::Gemfile.new(file_contents: 'bar app contents')
      )

      result = described_class.new(gemfile_gateway: gemfile_gateway)
        .execute(application_names: application_names)

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
end
