describe UseCases::FetchPullRequestCount do
  it 'calls the pull request count gateway' do
    gateway = double(execute: 10)
    result = described_class.new(pull_request_count_gateway: gateway).execute
    expect(gateway).to have_received(:execute).once
    expect(result).to eq(10)
  end
end
