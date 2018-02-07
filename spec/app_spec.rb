require 'spec_helper'
require 'rack/test'
require_relative '../app'

ENV['RACK_ENV'] = 'test'

describe GovukDependencies do
  include Rack::Test::Methods
  def app() described_class end

  context 'given open pull requests' do
    before do
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:approved')
        .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:required')
        .to_return(body: File.read('spec/fixtures/pull_requests.json'), headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:changes_requested')
        .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { 'Content-Type' => 'application/json' })
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
        expect(last_response.body).to include('#modelling-services')
        expect(last_response.body).to include('publisher (2)')
        expect(last_response.body).to include('#start-pages')
        expect(last_response.body).to include('frontend (1)')
      end

      it 'should filter by team' do
        get '/team/modelling-services'
        expect(last_response).to be_ok
        expect(last_response.body).to include('#modelling-services')
        expect(last_response.body).to include('publisher (2)')
        expect(last_response.body).to_not include('#start-pages')
        expect(last_response.body).to_not include('frontend (1)')
      end
    end
  end

  context 'given no open pull requests' do
    before do
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:approved')
        .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:required')
        .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:changes_requested')
        .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { 'Content-Type' => 'application/json' })
    end

    context 'Pull requests by application' do
      it 'should display the "no open pull requests" message' do
        get '/'
        expect(last_response).to be_ok
        expect(last_response.body).to include('No open pull requests 🎂')
      end
    end

    context 'Pull requests by gem' do
      it 'should display the "no open pull requests" message' do
        get '/gem'
        expect(last_response).to be_ok
        expect(last_response.body).to include('No open pull requests 🎂')
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

      it 'should display the "no open pull requests" message' do
        get '/team'
        expect(last_response).to be_ok
        expect(last_response.body).to include('No open pull requests 🎂')
      end
    end
  end

  context 'given pull requests that require review' do
    before do
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:approved')
        .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:required')
        .to_return(body: File.read('spec/fixtures/pull_requests.json'), headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:changes_requested')
        .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { 'Content-Type' => 'application/json' })
    end

    context 'application view' do
      it 'should not display anything next to the pull request title' do
        get '/'
        expect(last_response).to be_ok
        expect(last_response.body).not_to include('(approved)')
        expect(last_response.body).not_to include('(changes requested)')
      end
    end

    context 'gem view' do
      it 'should not display anything next to the pull request title' do
        get '/gem'
        expect(last_response).to be_ok
        expect(last_response.body).not_to include('(approved)')
        expect(last_response.body).not_to include('(changes requested)')
      end
    end
  end

  context 'given open approved pull requests' do
    before do
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:approved')
        .to_return(body: File.read('spec/fixtures/pull_requests.json'), headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:required')
        .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:changes_requested')
        .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { 'Content-Type' => 'application/json' })
    end

    context 'application view' do
      it 'should display a check mark next to the pull request title' do
        get '/'
        expect(last_response).to be_ok
        expect(last_response.body).to include('(approved)')
        expect(last_response.body).not_to include('(changes requested)')
      end
    end

    context 'gem view' do
      it 'should display a check mark next to the pull request title' do
        get '/gem'
        expect(last_response).to be_ok
        expect(last_response.body).to include('(approved)')
        expect(last_response.body).not_to include('(changes requested)')
      end
    end
  end

  context 'given pull requests that have changes requested' do
    before do
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:approved')
        .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:required')
        .to_return(body: '{ "total_count": 0, "incomplete_results": false, "items": [] }', headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+review:changes_requested')
        .to_return(body: File.read('spec/fixtures/pull_requests.json'), headers: { 'Content-Type' => 'application/json' })
    end

    context 'application view' do
      it 'should display the status next to the pull request title' do
        get '/'
        expect(last_response).to be_ok
        expect(last_response.body).not_to include('(approved)')
        expect(last_response.body).to include('(changes requested)')
      end
    end

    context 'gem view' do
      it 'should display the status to the pull request title' do
        get '/gem'
        expect(last_response).to be_ok
        expect(last_response.body).not_to include('(approved)')
        expect(last_response.body).to include('(changes requested)')
      end
    end
  end
end
