describe UseCases::SaveGemfiles do
  context 'Given no Gemfiles' do
    it 'does not save them' do
      fetch_gemfiles = double(execute: [])
      file = spy
      described_class.new(fetch_gemfiles: fetch_gemfiles, file: file).execute

      expect(file).to_not have_received(:write)
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
      file = spy
      described_class.new(fetch_gemfiles: fetch_gemfiles, file: file).execute

      expect(file).to have_received(:write).with('tmp/foo-app_gemfile.lock', 'some contents')
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

      file = spy
      described_class.new(fetch_gemfiles: fetch_gemfiles, file: file).execute

      expect(file).to have_received(:write).with('tmp/foo-app_gemfile.lock', 'foo contents')
      expect(file).to have_received(:write).with('tmp/bar-app_gemfile.lock', 'bar contents')
    end
  end
end
