require_relative '../dependaseal'

describe Dependaseal do
  before do
    ENV['SLACK_WEBHOOK_URL'] = 'http://example.com/webhook'

    stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot')
      .to_return(body: File.read('spec/fixtures/pull_requests.json'), headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "https://docs.publishing.service.gov.uk/apps.json")
      .to_return(
        body: File.read('spec/fixtures/multiple_teams_with_multiple_applications.json'),
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:post, "http://example.com/webhook")
  end

  it 'sends a message to slack for each team with open pull requests' do
    modelling_services_payload = {
      'payload' => '{"channel":"modelling-services","username":"Dependaseal","icon_emoji":":happyseal:","text":"You have 2 open Dependabot PR(s) - https://govuk-dependencies.herokuapp.com/team/modelling-services"}'
    }
    start_pages_payload = {
      'payload' => '{"channel":"start-pages","username":"Dependaseal","icon_emoji":":happyseal:","text":"You have 1 open Dependabot PR(s) - https://govuk-dependencies.herokuapp.com/team/start-pages"}'
    }

    described_class.new.execute

    expect(a_request(:post, ENV['SLACK_WEBHOOK_URL']).with(body: modelling_services_payload)).to have_been_made
    expect(a_request(:post, ENV['SLACK_WEBHOOK_URL']).with(body: start_pages_payload)).to have_been_made
  end
end
