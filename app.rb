require 'sinatra'

class GovukDependencies < Sinatra::Base
  get '/' do
    'Hello world!'
  end
end
