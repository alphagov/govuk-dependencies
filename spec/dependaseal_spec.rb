require_relative '../dependaseal'

describe Dependaseal do
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
        'payload' => '{"channel":"modelling-services","username":"Dependaseal","icon_emoji":":happyseal:","text":"You have 2 open Dependabot PR(s) - https://govuk-dependencies.herokuapp.com/team/modelling-services - Feedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback"}'
      }

      start_pages_payload = {
        'payload' => '{"channel":"start-pages","username":"Dependaseal","icon_emoji":":happyseal:","text":"You have 1 open Dependabot PR(s) - https://govuk-dependencies.herokuapp.com/team/start-pages - Feedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback"}'
      }

      described_class.new.send_simple_message

      expect(a_request(:post, ENV['SLACK_WEBHOOK_URL']).with(body: modelling_services_payload)).to have_been_made
      expect(a_request(:post, ENV['SLACK_WEBHOOK_URL']).with(body: start_pages_payload)).to have_been_made
    end
  end

  context 'Full Message' do
    it 'sends all the pull requests in the message' do
      modelling_services_payload = {
        'payload' => '{"channel":"modelling-services","username":"Dependaseal","icon_emoji":":happyseal:","text":"#modelling-services You have 2 Dependabot PRs open on the following apps:\n\npublisher https://github.com/alphagov/publisher/pulls/app/dependabot\n\nFeedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback"}'
      }

      start_pages_payload = {
        'payload' => '{"channel":"start-pages","username":"Dependaseal","icon_emoji":":happyseal:","text":"#start-pages You have 1 Dependabot PRs open on the following apps:\n\nfrontend https://github.com/alphagov/frontend/pulls/app/dependabot\n\nFeedback: https://trello.com/b/jQrIfH9A/dependabot-developer-feedback"}'
      }

      described_class.new.send_full_message

      expect(a_request(:post, ENV['SLACK_WEBHOOK_URL']).with(body: modelling_services_payload)).to have_been_made
      expect(a_request(:post, ENV['SLACK_WEBHOOK_URL']).with(body: start_pages_payload)).to have_been_made
    end
  end
end
