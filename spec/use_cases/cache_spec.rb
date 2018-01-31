describe UseCases::Cache do
  context 'Given the result has not been cached' do
    it 'caches the result' do
      file = double(exists?: false)
      expect(file).to receive(:open)
      described_class.new(name: 'foo', file: file).execute do
        'some cached result'
      end
    end

    it 'returns the result' do
      file = double(exists?: false, open: nil)
      result = described_class.new(name: 'foo', file: file).execute do
        'some cached result'
      end

      expect(result).to eq('some cached result')
    end
  end

  context 'Given the result has been previously cached' do
    it 'returns the cached result' do
      file = double(exists?: true, mtime: Time.now, read: 'foo')
      result = described_class.new(name: 'foo.html', file: file).execute { }
      expect(result).to eq('foo')
    end
  end

  context 'Given the cache is invalid' do
    it 'populates the cache' do
      file = double(exists?: true, mtime: Time.now - 121, open: nil)
      expect(file).to receive(:open)
      described_class.new(name: 'foo', file: file).execute {}
    end
  end
end
