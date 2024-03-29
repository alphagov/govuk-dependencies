require_relative "../../dependapanda"
require "spec_helper"

describe Dependapanda do
  around do |example|
    ClimateControl.modify GITHUB_TOKEN: "some_token" do
      VCR.use_cassette("repositories") do
        Timecop.freeze("2019-09-27") do
          example.run
        end
      end
    end
  end

  before do
    ENV["SLACK_WEBHOOK_URL"] = "http://example.com/webhook"

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+archived:false+review:approved")
      .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { "Content-Type" => "application/json" })
    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+archived:false+review:required")
      .to_return(body: File.read("spec/fixtures/pull_requests.json"), headers: { "Content-Type" => "application/json" })
    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+archived:false+review:changes_requested")
      .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { "Content-Type" => "application/json" })

    stub_request(:get, "https://docs.publishing.service.gov.uk/repos.json")
      .to_return(
        body: File.read("spec/fixtures/multiple_teams_with_multiple_applications.json"),
        headers: { "Content-Type" => "application/json" },
      )

    stub_request(:post, "http://example.com/webhook")
  end

  context "Simple Message" do
    it "sends a summarised message" do
      govuk_platform_health_payload = {
        "payload" => '{"channel":"govuk-platform-health","username":"Dependapanda","icon_emoji":":panda_face:","text":"You have 3 open Dependabot PR(s) - https://govuk-dependencies.herokuapp.com/team/govuk-platform-health"}',
      }

      described_class.new.send_simple_message

      expect(a_request(:post, ENV["SLACK_WEBHOOK_URL"]).with(body: govuk_platform_health_payload)).to have_been_made
    end
  end

  context "Full Message" do
    it "sends all the pull requests in the message" do
      govuk_platform_health_payload = {
        "payload" => '{"channel":"govuk-platform-health","username":"Dependapanda","icon_emoji":":panda_face:","text":"<https://govuk-dependencies.herokuapp.com/team/govuk-platform-health|govuk-platform-health> have 3 Dependabot PRs open on the following apps:\n\n<https://github.com/alphagov/publisher/pulls?q=is:pr+is:open+label:dependencies|publisher> (2, oldest one opened 611 days ago)\n<https://github.com/alphagov/frontend/pulls?q=is:pr+is:open+label:dependencies|frontend> (1, opened 611 days ago)"}',
      }

      described_class.new.send_full_message

      expect(a_request(:post, ENV["SLACK_WEBHOOK_URL"]).with(body: govuk_platform_health_payload)).to have_been_made
    end
  end

  context "When the Slack channel does not exist" do
    it "sends a notification to the govuk-platform-reliability-team channel" do
      govuk_platform_health_payload = {
        "payload" => '{"channel":"govuk-platform-reliability-team","username":"Dependapanda","icon_emoji":":panda_face:","text":"Couldn\'t send message to channel \"govuk-platform-health\" (channel not found)"}',
      }

      stub_request(:post, ENV["SLACK_WEBHOOK_URL"])
        .with { |req| req.body !~ /govuk-platform-reliability-team/ }
        .to_return(
          status: 404,
          body: "channel_not_found",
        )

      described_class.new.send_simple_message

      expect(a_request(:post, ENV["SLACK_WEBHOOK_URL"]).with(body: govuk_platform_health_payload)).to have_been_made
    end
  end
end
