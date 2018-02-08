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
      pull_requests = UseCases::FetchPullRequests.new.execute
      teams = UseCases::FetchTeams.new.execute
      applications_by_team = UseCases::GroupApplicationsByTeam.new.execute(pull_requests: pull_requests, teams: teams)

      erb :team, locals: { pull_requests_by_team: applications_by_team }, layout: :layout
    end
  end

  get '/team/:team_name' do
    cache :"pull_requests_by_team_#{params.fetch(:team_name)}" do
      pull_requests = UseCases::FetchPullRequests.new.execute
      teams = UseCases::FetchTeams.new.execute
      applications_by_team = UseCases::GroupApplicationsByTeam.new.execute(pull_requests: pull_requests, teams: teams)

      applications_for_team = applications_by_team.select do |team|
        team.fetch(:team_name) == params.fetch(:team_name)
      end

      erb :team, locals: { pull_requests_by_team: applications_for_team }, layout: :layout
    end
  end

  post '/slack/notify/:team' do
    message_presenter = Presenters::Slack::FullMessage.new
    UseCases::SendSlackMessages.new(message_presenter: message_presenter).execute(team: params.fetch(:team))
    '[ok]'
  end
end
