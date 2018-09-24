require_relative '../../dependapanda'

describe Dependapanda do
  around do |example|
    ClimateControl.modify GITHUB_TOKEN: "some_token" do
      VCR.use_cassette("repositories") do
        example.run
      end
    end
  end

  before do
    ENV['SLACK_WEBHOOK_URL'] = 'http://example.com/webhook'

    stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:approved')
      .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:required')
      .to_return(body: File.read('spec/fixtures/pull_requests.json'), headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:changes_requested')
      .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "https://docs.publishing.service.gov.uk/apps.json")
      .to_return(
        body: File.read('spec/fixtures/multiple_teams_with_multiple_applications.json'),
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:post, "http://example.com/webhook")
  end

  context 'Simple Message' do
    it 'sends a summarised message' do
      modelling_services_payload = {
        'payload' => '{"channel":"modelling-services","username":"Dependapanda","icon_emoji":":panda_face:","text":"You have 2 open Dependabot PR(s) - https://govuk-dependencies.herokuapp.com/team/modelling-services"}'
      }

      start_pages_payload = {
        'payload' => '{"channel":"start-pages","username":"Dependapanda","icon_emoji":":panda_face:","text":"You have 1 open Dependabot PR(s) - https://govuk-dependencies.herokuapp.com/team/start-pages"}'
      }

      described_class.new.send_simple_message

      expect(a_request(:post, ENV['SLACK_WEBHOOK_URL']).with(body: modelling_services_payload)).to have_been_made
      expect(a_request(:post, ENV['SLACK_WEBHOOK_URL']).with(body: start_pages_payload)).to have_been_made
    end
  end

  context 'Full Message' do
    it 'sends all the pull requests in the message' do
      modelling_services_payload = {
        'payload' => '{"channel":"modelling-services","username":"Dependapanda","icon_emoji":":panda_face:","text":"<https://govuk-dependencies.herokuapp.com/team/modelling-services|modelling-services> have 2 Dependabot PRs open on the following apps:\n\n<https://github.com/alphagov/publisher/pulls/app/dependabot|publisher> (2)"}'
      }

      start_pages_payload = {
        'payload' => '{"channel":"start-pages","username":"Dependapanda","icon_emoji":":panda_face:","text":"<https://govuk-dependencies.herokuapp.com/team/start-pages|start-pages> have 1 Dependabot PRs open on the following apps:\n\n<https://github.com/alphagov/frontend/pulls/app/dependabot|frontend> (1)"}'
      }

      described_class.new.send_full_message

      expect(a_request(:post, ENV['SLACK_WEBHOOK_URL']).with(body: modelling_services_payload)).to have_been_made
      expect(a_request(:post, ENV['SLACK_WEBHOOK_URL']).with(body: start_pages_payload)).to have_been_made
    end
  end
end
