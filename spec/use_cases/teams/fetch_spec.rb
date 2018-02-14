describe UseCases::Teams::Fetch do
  it 'Calls execute on the gateway' do
    teams_gateway = double(execute: [])
    expect(teams_gateway).to receive(:execute).once

    described_class.new(teams_gateway: teams_gateway).execute
  end
end
