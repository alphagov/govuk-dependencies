require 'sinatra'
require_relative 'lib/loader'

def cache(name)
  return yield if ENV['RACK_ENV'] == 'test'

  UseCases::Cache.new(path: "#{Dir.pwd}/public/cache/#{name}.html").execute { yield }
end

class GovukDependencies < Sinatra::Base
  get '/' do
    cache :pull_requests_by_application do
      ungrouped_pull_requests = UseCases::FetchPullRequests.new.execute
      @pull_requests_by_application = Presenters::PullRequestsByApplication.new.execute(ungrouped_pull_requests)
      erb :index, layout: :layout
    end
  end

  get '/gem' do
    cache :pull_requests_by_gem do
      ungrouped_pull_requests = UseCases::FetchPullRequests.new.execute
      @pull_requests_by_gem = Presenters::PullRequestsByGem.new.execute(ungrouped_pull_requests)

      erb :gem, layout: :layout
    end
  end

  get '/team' do
    cache :pull_requests_by_team do
      ungrouped_pull_requests = UseCases::FetchPullRequests.new.execute
      teams = UseCases::FetchTeams.new.execute
      pull_requests_by_team = Presenters::PullRequestsByTeam.new.execute(
        teams: teams,
        ungrouped_pull_requests: ungrouped_pull_requests
      )

      erb :team, locals: { pull_requests_by_team: pull_requests_by_team }, layout: :layout
    end
  end

  get '/team/:team_name' do
    cache :"pull_requests_by_team_#{params.fetch(:team_name)}" do
      ungrouped_pull_requests = UseCases::FetchPullRequests.new.execute
      teams = UseCases::FetchTeams.new.execute
      grouped_pull_requests = Presenters::PullRequestsByTeam.new.execute(
        teams: teams,
        ungrouped_pull_requests: ungrouped_pull_requests
      )

      pull_requests_for_team = grouped_pull_requests.select do |team|
        team.fetch(:team_name) == '#' + params.fetch(:team_name)
      end

      erb :team, locals: { pull_requests_by_team: pull_requests_for_team }, layout: :layout
    end
  end
end
