describe UseCases::SaveGemfiles do
  context 'Given FetchGemfiles' do
    it 'calls execute' do
      fetch_gemfiles = spy
      described_class.new(fetch_gemfiles: fetch_gemfiles).execute

      expect(fetch_gemfiles).to have_received(:execute)
    end
  end

  context 'Given no Gemfiles' do
    it 'does not save them' do
      fetch_gemfiles = double(execute: [])
      file_gateway = spy
      described_class.new(fetch_gemfiles: fetch_gemfiles, file: file_gateway).execute

      expect(file_gateway).to_not have_received(:execute)
    end
  end

  context 'Given one Gemfile' do
    it 'saves it' do
      fetch_gemfiles = double(execute: [
        {
          application_name: 'foo-app',
          gemfile_contents: 'some contents'
        }
      ])
      file_gateway = spy
      described_class.new(fetch_gemfiles: fetch_gemfiles, file: file_gateway).execute

      expect(file_gateway).to have_received(:open).with('tmp/foo-app_gemfile.lock', 'w')
    end
  end

  context 'Given many Gemfiles' do
    it 'saves them' do
      fetch_gemfiles = double(execute: [
        {
          application_name: 'foo-app',
          gemfile_contents: 'foo contents'
        }, {
          application_name: 'bar-app',
          gemfile_contents: 'bar contents'
        }
      ])

      file_gateway = spy

      described_class.new(fetch_gemfiles: fetch_gemfiles, file: file_gateway).execute

      expect(file_gateway).to have_received(:open).with('tmp/foo-app_gemfile.lock', 'w')
      expect(file_gateway).to have_received(:open).with('tmp/bar-app_gemfile.lock', 'w')
    end
  end
end
