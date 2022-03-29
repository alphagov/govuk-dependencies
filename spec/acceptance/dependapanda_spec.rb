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

    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+author:app/dependabot-preview+review:approved")
      .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { "Content-Type" => "application/json" })
    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+author:app/dependabot-preview+review:required")
      .to_return(body: File.read("spec/fixtures/pull_requests.json"), headers: { "Content-Type" => "application/json" })
    stub_request(:get, "https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+author:app/dependabot-preview+review:changes_requested")
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
        "payload" => '{"channel":"govuk-platform-health","username":"Dependapanda","icon_emoji":":panda_face:","text":"<https://govuk-dependencies.herokuapp.com/team/govuk-platform-health|govuk-platform-health> have 3 Dependabot PRs open on the following apps:\n\n<https://github.com/alphagov/publisher/pulls?q=is:pr+is:open+label:dependencies|publisher> (2) <https://github.com/alphagov/frontend/pulls?q=is:pr+is:open+label:dependencies|frontend> (1)"}',
      }

      described_class.new.send_full_message

      expect(a_request(:post, ENV["SLACK_WEBHOOK_URL"]).with(body: govuk_platform_health_payload)).to have_been_made
    end
  end
end
