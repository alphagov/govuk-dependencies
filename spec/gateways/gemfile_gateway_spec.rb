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
end
