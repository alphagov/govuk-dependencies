describe UseCases::FetchPullRequests do
  it 'Calls execute on the gateway' do
    pull_request_gateway = double
    expect(pull_request_gateway).to receive(:execute).once

    described_class.new(gateway: pull_request_gateway).execute
  end
end
