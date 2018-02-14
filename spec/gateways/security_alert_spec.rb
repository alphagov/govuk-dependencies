describe Gateways::SecurityAlert do
  context 'with no security alerts for application' do
    it 'returns an empty array' do
      FileUtils.cp('spec/fixtures/gemfile_with_no_security_alerts', 'tmp/signon_gemfile.lock')
      result = described_class.new.execute(application_name: 'signon')

      expect(result).to eq([])
    end
  end

  context 'with security alerts for application' do
    context 'with no criticality' do
      it 'returns an empty list' do
        FileUtils.cp('spec/fixtures/gemfile_with_nil_criticality', 'tmp/signon_gemfile.lock')
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

        expect(result.first.gem).to eq(expected.gem)
        expect(result.first.criticality).to eq(expected.criticality)
        expect(result.first.patched_versions).to eq(expected.patched_versions)
      end
    end
  end

  after(:all) do
    FileUtils.rm('tmp/signon_gemfile.lock')
  end
end
