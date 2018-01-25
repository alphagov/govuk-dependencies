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

  it 'should show both applications with the number of open pull requests' do
    get '/'
    expect(last_response.body).to include('frontend (1)')
    expect(last_response.body).to include('publisher (2)')
  end
end
