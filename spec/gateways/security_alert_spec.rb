describe Gateways::SecurityAlert do
  let(:scanner) { double }

  context 'with no security alerts for application' do
    it 'returns an empty array' do
      allow(scanner).to receive(:scan).and_return([])
      allow(Bundler::Audit::Scanner).to receive(:new).with(any_args).and_return(scanner)
      result = described_class.new.execute(application_name: 'signon')

      expect(result).to eq([])
    end
  end

  context 'with security alerts for application' do
    context 'with no criticality' do
      it 'returns an empty list' do
        allow(scanner).to receive(:scan).and_return([])
        allow(Bundler::Audit::Scanner).to receive(:new).with(any_args).and_return(scanner)
        result = described_class.new.execute(application_name: 'signon')

        expect(result).to eq([])
      end
    end

    context 'with criticality' do
      it 'returns a security alert with criticality' do
        expected = Domain::SecurityAlert.new(
          gem: 'rubocop',
          criticality: 'low',
          patched_versions: '>= 0.49.0'
        )

        FileUtils.cp('spec/fixtures/gemfile_with_criticality', 'tmp/signon_gemfile.lock')
        result = described_class.new.execute(application_name: 'signon')

        expect(result).to include(expected)
      end
    end
  end

  after(:all) do
    FileUtils.rm('tmp/signon_gemfile.lock')
  end
end
