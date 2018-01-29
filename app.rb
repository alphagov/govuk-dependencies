require 'sinatra'
require_relative 'lib/loader'

class GovukDependencies < Sinatra::Base
  get '/' do
    ungrouped_pull_requests = UseCases::FetchPullRequests.new.execute
    @pull_requests_by_application = Presenters::PullRequestsByApplication.new.execute(ungrouped_pull_requests)
    erb :index
  end

  get '/gem' do
    ungrouped_pull_requests = UseCases::FetchPullRequests.new.execute
    @pull_requests_by_gem = Presenters::PullRequestsByGem.new.execute(ungrouped_pull_requests)
    erb :gem
  end

  get '/team' do
    ungrouped_pull_requests = UseCases::FetchPullRequests.new.execute
    teams = UseCases::FetchTeams.new.execute
    @pull_requests_by_team = Presenters::PullRequestsByTeam.new.execute(
      teams: teams,
      ungrouped_pull_requests: ungrouped_pull_requests
    )
    erb :team
  end
end
