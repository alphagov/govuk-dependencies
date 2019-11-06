require "sinatra"
require_relative "lib/loader"

class GovukDependencies < Sinatra::Base
  get "/" do
    cache :pull_requests_by_application do
      erb :index, layout: :layout, locals: {
        pull_requests_by_application: UseCases::Group::PullRequestsByApplication.new.execute,
      }
    end
  end

  get "/gem" do
    cache :pull_requests_by_gem do
      erb :gem, layout: :layout, locals: {
        pull_requests_by_gem: UseCases::Group::PullRequestsByGem.new.execute,
      }
    end
  end

  get "/team" do
    cache :pull_requests_by_team do
      pull_requests = UseCases::PullRequests::Fetch.new.execute
      teams = UseCases::Teams::Fetch.new.execute
      applications_by_team = UseCases::Group::ApplicationsByTeam.new.execute(pull_requests: pull_requests, teams: teams)

      erb :team, locals: { pull_requests_by_team: applications_by_team }, layout: :layout
    end
  end

  get "/stats" do
    cache :stats do
      erb :stats, locals: {
        pull_request_count: UseCases::PullRequests::FetchCount.new.execute,
      }, layout: :layout
    end
  end

  get "/team/:team_name" do
    cache :"pull_requests_by_team_#{params.fetch(:team_name)}" do
      pull_requests = UseCases::PullRequests::Fetch.new.execute
      teams = UseCases::Teams::Fetch.new.execute
      applications_by_team = UseCases::Group::ApplicationsByTeam.new.execute(pull_requests: pull_requests, teams: teams)

      applications_for_team = applications_by_team.select do |team|
        team.fetch(:team_name) == params.fetch(:team_name)
      end

      erb :team, locals: { pull_requests_by_team: applications_for_team }, layout: :layout
    end
  end

  post "/slack/notify/:team/:secret" do
    return "[unauthorised]" unless params[:secret] == ENV["DEPENDAPANDA_SECRET"]

    UseCases::Slack::SendMessages.new(
      message_presenter: Presenters::Slack::FullMessage.new,
    ).execute(team: params.fetch(:team))
    "[ok]"
  end
end
