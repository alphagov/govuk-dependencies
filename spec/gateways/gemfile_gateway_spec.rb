describe Gateways::Gemfile do
  context 'when getting a Gemfile' do
    before do
      stub_request(:get, 'https://raw.githubusercontent.com/alphagov/govuk-dependencies/master/Gemfile.lock')
        .to_return(body: File.open('spec/fixtures/Gemfile.lock'))
    end

    it 'returns a Gemfile Domain Object' do
      result = described_class.new.execute(application_name: 'govuk-dependencies')
      expect(result.file_contents).to include('remote: https://rubygems.org/')
    end
  end

  context 'An application has no Gemfile' do
    before do
      stub_request(:get, 'https://raw.githubusercontent.com/alphagov/mapit/master/Gemfile.lock')
        .to_return(status: 404)
    end

    it 'suppresses the not found exception' do
      expect {
        described_class.new.execute(application_name: 'mapit')
      }.to_not raise_error
    end
  end
end
