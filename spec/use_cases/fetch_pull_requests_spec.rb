describe UseCases::FetchPullRequests do
  it 'Returns an empty array given no pull requests' do
    gateway = stub(execute: [])
    result = described_class.new(gateway: gateway).execute
    expect(result).to be_empty
  end
end

