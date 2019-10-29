describe Presenters::Slack::SimpleMessage do
  context "Given a single pull request and a team" do
    it "formats the message" do
      applications_by_team = {
        team_name: "email",
        applications: [
          {
            application_name: "content-tagger",
            application_url: "https://github.com/alphagov/content-tagger?is:pr+is:open+label:dependencies",
            pull_request_count: 1,
          },
        ],
      }
      result = described_class.new.execute(applications_by_team: applications_by_team)

      expect(result).to eq("You have 1 open Dependabot PR(s) - https://govuk-dependencies.herokuapp.com/team/email")
    end
  end
end
