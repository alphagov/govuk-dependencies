require 'spec_helper'
require 'rack/test'
require_relative '../app'

ENV['RACK_ENV'] = 'test'

describe GovukDependencies do
  include Rack::Test::Methods
  def app() described_class end

  it "should allow accessing the home page" do
    get '/'
    expect(last_response).to be_ok
  end
end
