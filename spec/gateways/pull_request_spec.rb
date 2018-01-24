describe Gateways::PullRequest do
  context '' do
    it 'Returns an empty array' do
      result = described_class.new.execute
      expect(result).to be_empty
    end
  end

  it 'Returns a list of pull requests' do

  end
end
