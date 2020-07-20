require "spec_helper"

describe UseCases::Distribute::OverflowToDevelopersChannel do
  let(:prs_by_team) do
    [
      {
        team_name: "govuk-platform-health",
        applications:
          [
            { application_name: "whitehall", pull_request_count: 5 },
            { application_name: "signon", pull_request_count: 4 },
            { application_name: "ckanext-datagovuk", pull_request_count: 3 },
            { application_name: "collections-publisher", pull_request_count: 2 },
            { application_name: "content-data-admin", pull_request_count: 1 },
            { application_name: "content-publisher", pull_request_count: 1 },
            { application_name: "support", pull_request_count: 1 },
          ],
      },
      {
        team_name: "govuk-top-team",
        applications:
          [
            { application_name: "not-another-whitehall", pull_request_count: 1 },
          ],
      },
    ]
  end

  RSpec::Matchers.define :have_application_count_for_team do |expected, team_name|
    def number_of_apps(teams, team_name)
      teams.inject(0) do |sum, team_and_apps|
        sum = team_and_apps[:applications].count if team_and_apps[:team_name] == team_name
        sum
      end
    end
    match do |actual|
      expected == number_of_apps(actual, team_name)
    end
    failure_message do |actual|
      "expected #{team_name} to have #{expected} application(s) but it actually has #{number_of_apps(actual, team_name)}"
    end
  end

  def distribute(prs, overflow_at)
    UseCases::Distribute::OverflowToDevelopersChannel.new.execute(
      application_prs_by_team: prs,
      overflow_at: overflow_at,
    )
  end

  context "when there is no overflow for a team" do
    let(:no_overflow) do
      distribute(prs_by_team, 10)
    end

    it "should not create the govuk-developers team" do
      expect(no_overflow).not_to satisfy("contain a team name govuk-developers") do |v|
        v.any? do |team_application_hash|
          team_application_hash[:team_name] == "govuk-developers"
        end
      end
    end

    it "should not redistribute any apps" do
      expect(no_overflow).to have_application_count_for_team(7, "govuk-platform-health")
    end
  end

  context "when there is overflow for a team" do
    let(:overflow) do
      distribute(prs_by_team, 5)
    end

    it "should create the govuk-developers team" do
      expect(overflow).to satisfy("contain a team name govuk-developers") do |v|
        v.any? do |team_application_hash|
          team_application_hash[:team_name] == "govuk-developers"
        end
      end
    end

    it "should assign the overflow to govuk-developers" do
      expect(overflow).to have_application_count_for_team(5, "govuk-platform-health")
      expect(overflow).to have_application_count_for_team(2, "govuk-developers")
      expect(overflow).to have_application_count_for_team(1, "govuk-top-team")
    end
  end

  context "when govuk-developers team already exists" do
    let(:extra_team) do
      [
        {
          team_name: "govuk-developers",
          applications:
          [
            { application_name: "sardines", pull_request_count: 3 },
            { application_name: "smoked-salmon", pull_request_count: 2 },
            { application_name: "chopped-liver", pull_request_count: 2 },
            { application_name: "pickled-herring", pull_request_count: 2 },
          ],
        },
      ]
    end

    let(:overflow_with_dev_team) do
      distribute(prs_by_team + extra_team, 5)
    end

    it "should not create a second govuk-developers team" do
      number_of_govuk_developers_teams = overflow_with_dev_team.count { |h| h[:team_name] == "govuk-developers" }

      expect(number_of_govuk_developers_teams).to eq(1)
    end

    it "should append the overflow to govuk-developers" do
      expect(overflow_with_dev_team).to have_application_count_for_team(6, "govuk-developers")
    end
  end
end
