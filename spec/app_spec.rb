require 'spec_helper'
require 'rack/test'
require_relative '../app'

ENV['RACK_ENV'] = 'test'

describe GovukDependencies do
  include Rack::Test::Methods
  def app() described_class end

  before do
    stub_request(:get, 'https://api.github.com/search/issues?q=is:pr+user:alphagov+state:open+author:app/dependabot')
      .to_return(body: File.read('spec/fixtures/pull_requests.json'), headers: { 'Content-Type' => 'application/json' })
  end

  context 'Pull request by application' do
    it 'should show both applications with the number of open pull requests' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to include('frontend (1)')
      expect(last_response.body).to include('publisher (2)')
    end
  end

  context 'Pull requests by gem' do
    it 'should show both gems with the number applications with pull requests' do
      get '/gem'
      expect(last_response).to be_ok
      expect(last_response.body).to include('gds-sso (2)')
      expect(last_response.body).to include('gds-api-adapters (1)')
    end
  end

  context 'Pull requests by team' do
    before do
      stub_request(:get, "https://docs.publishing.service.gov.uk/apps.json")
      .to_return(
        body: File.read('spec/fixtures/multiple_teams_with_multiple_applications.json'),
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    it 'should show both teams with the number applications with pull requests' do
      get '/team'
      expect(last_response).to be_ok
      expect(last_response.body).to include('#asset-management (2)')
      expect(last_response.body).to include('#email (1)')
    end
  end
end
