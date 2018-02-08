require 'sinatra'
require_relative 'lib/loader'

def cache(name)
  return yield unless ENV['RACK_ENV'] == 'production'

  UseCases::Cache.new(path: "#{Dir.pwd}/public/cache/#{name}.html").execute { yield }
end

def old_pull_request?(date)
  today = Date.today
  actual_age = (today - date).to_i
  weekdays_age = if today.monday?
                   actual_age - 2
                 elsif today.tuesday?
                   actual_age - 1
                 else
                   actual_age
                 end
  weekdays_age > 2
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

  get '/stats' do
    cache :stats do
      pull_request_count = UseCases::FetchPullRequestCount.new.execute

      erb :stats, locals: { pull_request_count: pull_request_count }, layout: :layout
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
        team.fetch(:team_name) == params.fetch(:team_name)
      end

      erb :team, locals: { pull_requests_by_team: pull_requests_for_team }, layout: :layout
    end
  end
end
