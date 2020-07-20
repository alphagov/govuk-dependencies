describe UseCases::PullRequests::Fetch do
  it "Calls execute on the gateway" do
    pull_request_gateway = double(execute: [])
    result = described_class.new(gateway: pull_request_gateway).execute
    expect(result).to eq([])
  end

  context "Given one pull request" do
    it "returns a single formtted result" do
      pull_request_gateway = double(execute: [
        Domain::PullRequest.new(
          application_name: "frontend",
          title: "Bump Rails from 4.2 to 5.0",
          opened_at: Date.today,
          status: "approved",
          url: "https://github.com/alphagov/frontend/pulls/123",
        ),
      ])

      result = described_class.new(gateway: pull_request_gateway).execute

      expect(result).to eq([{
        application_name: "frontend",
        title: "Bump Rails from 4.2 to 5.0",
        url: "https://github.com/alphagov/frontend/pulls/123",
        opened_at: Date.today,
        status: "approved",
        open_since: "today",
      }])
    end

    context "with a pull request which bumps two gems" do
      it "returns two pull request hashes" do
        pull_request_gateway = double(execute: [
          Domain::PullRequest.new(
            application_name: "frontend",
            title: "Bump Rails and gds-api-adapters",
            opened_at: Date.today,
            status: "approved",
            url: "https://github.com/alphagov/frontend/pulls/123",
          ),
        ])

        result = described_class.new(gateway: pull_request_gateway).execute

        expect(result).to eq([{
          application_name: "frontend",
          title: "Bump Rails",
          url: "https://github.com/alphagov/frontend/pulls/123",
          opened_at: Date.today,
          status: "approved",
          open_since: "today",
        },
                              {
                                application_name: "frontend",
                                title: "Bump gds-api-adapters",
                                url: "https://github.com/alphagov/frontend/pulls/123",
                                opened_at: Date.today,
                                status: "approved",
                                open_since: "today",
                              }])
      end
    end

    context "with a pull request which bumps three gems" do
      it "returns three pull request hashes" do
        pull_request_gateway = double(execute: [
          Domain::PullRequest.new(
            application_name: "frontend",
            title: "Bump Rails, Rspec and gds-api-adapters",
            opened_at: Date.today,
            status: "approved",
            url: "https://github.com/alphagov/frontend/pulls/123",
          ),
        ])

        result = described_class.new(gateway: pull_request_gateway).execute

        expect(result).to eq([{
          application_name: "frontend",
          title: "Bump Rails",
          url: "https://github.com/alphagov/frontend/pulls/123",
          status: "approved",
          opened_at: Date.today,
          open_since: "today",
        },
                              {
                                application_name: "frontend",
                                title: "Bump Rspec",
                                url: "https://github.com/alphagov/frontend/pulls/123",
                                status: "approved",
                                opened_at: Date.today,
                                open_since: "today",
                              },
                              {
                                application_name: "frontend",
                                title: "Bump gds-api-adapters",
                                url: "https://github.com/alphagov/frontend/pulls/123",
                                status: "approved",
                                opened_at: Date.today,
                                open_since: "today",
                              }])
      end
    end
  end

  context "Given multiple pull requests" do
    it "returns a list of formatted results" do
      pull_request_gateway = double(execute: [
        Domain::PullRequest.new(
          application_name: "frontend",
          title: "Bump Rails from 4.2 to 5.0",
          opened_at: Date.today,
          status: "approved",
          url: "https://github.com/alphagov/frontend/pulls/123",
        ),
        Domain::PullRequest.new(
          application_name: "publisher",
          title: "Bump Rails from 3.2 to 4.0",
          opened_at: Date.today,
          status: "changes requested",
          url: "https://github.com/alphagov/publisher/pulls/123",
        ),
      ])

      result = described_class.new(gateway: pull_request_gateway).execute

      expect(result).to eq([
        {
          application_name: "frontend",
          title: "Bump Rails from 4.2 to 5.0",
          url: "https://github.com/alphagov/frontend/pulls/123",
          status: "approved",
          opened_at: Date.today,
          open_since: "today",
        },
        {
          application_name: "publisher",
          title: "Bump Rails from 3.2 to 4.0",
          url: "https://github.com/alphagov/publisher/pulls/123",
          status: "changes requested",
          opened_at: Date.today,
          open_since: "today",
        },
      ])
    end
  end
end
