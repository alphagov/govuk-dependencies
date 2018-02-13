describe Gateways::File do
  context 'writing a file' do
    after do
      FileUtils.rm('spec/tmp/foo.txt')
    end

    it 'writes a file' do
      file_path = 'spec/tmp/foo.txt'
      file_contents = 'some content'

      described_class.new.write(file_path, file_contents)

      expect(File.exist?(file_path)).to be true
      expect(File.read(file_path)).to eq file_contents
    end
  end
end
