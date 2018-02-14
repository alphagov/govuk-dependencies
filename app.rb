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
      @pull_requests_by_application = UseCases::GroupPullRequestsByApplication.new(
        fetch_pull_requests: UseCases::FetchPullRequests.new
      ).execute
      erb :index, layout: :layout
    end
  end

  get '/gem' do
    cache :pull_requests_by_gem do
      @pull_requests_by_gem = UseCases::GroupPullRequestsByGem.new(
        fetch_pull_requests: UseCases::FetchPullRequests.new
      ).execute

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

  get '/stats' do
    cache :stats do
      pull_request_count = UseCases::FetchPullRequestCount.new.execute

      erb :stats, locals: { pull_request_count: pull_request_count }, layout: :layout
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

  post '/slack/notify/:team/:secret' do
    return '[unauthorised]' unless params[:secret] == ENV['DEPENDAPANDA_SECRET']

    message_presenter = Presenters::Slack::FullMessage.new
    UseCases::Slack::SendMessages.new(message_presenter: message_presenter).execute(team: params.fetch(:team))
    '[ok]'
  end
end
