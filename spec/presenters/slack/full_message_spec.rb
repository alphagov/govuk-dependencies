describe Presenters::Slack::FullMessage do
  context "Given a single pull request" do
    it "formats the message" do
      applications_by_team = {
        team_name: "email",
        applications: [
          {
            application_name: "content-tagger",
            application_url: "https://github.com/alphagov/content-tagger?q=is:pr+is:open+label:dependencies",
            pull_request_count: 1,
            oldest_pr: "3 days ago",
          },
        ],
      }

      result = described_class.new.execute(applications_by_team: applications_by_team)

      expect(result).to eq('<https://govuk-dependencies.herokuapp.com/team/email|email> have 1 Dependabot PRs open on the following apps:

<https://github.com/alphagov/content-tagger/pulls?q=is:pr+is:open+label:dependencies|content-tagger> (1, opened 3 days ago)')
    end
  end

  context "Given multiple pull requests" do
    it "formats the message" do
      applications_by_team = {
        team_name: "taxonomy",
        applications: [
          {
            application_name: "collections-publisher",
            application_url: "https://github.com/alphagov/content-publisher?q=is:pr+is:open+label:dependencies",
            pull_request_count: 1,
            oldest_pr: "3 days ago",
          },
          {
            application_name: "content-tagger",
            application_url: "https://github.com/alphagov/content-tagger?q=is:pr+is:open+label:dependencies",
            pull_request_count: 1,
            oldest_pr: "3 days ago",
          },
        ],
      }

      result = described_class.new.execute(applications_by_team: applications_by_team)

      expect(result).to eq('<https://govuk-dependencies.herokuapp.com/team/taxonomy|taxonomy> have 2 Dependabot PRs open on the following apps:

<https://github.com/alphagov/collections-publisher/pulls?q=is:pr+is:open+label:dependencies|collections-publisher> (1, opened 3 days ago)
<https://github.com/alphagov/content-tagger/pulls?q=is:pr+is:open+label:dependencies|content-tagger> (1, opened 3 days ago)')
    end

    it "groups by application" do
      applications_by_team = {
        team_name: "taxonomy",
        applications: [
          {
            application_name: "collections-publisher",
            application_url: "https://github.com/alphagov/content-publisher?q=is:pr+is:open+label:dependencies",
            pull_request_count: 1,
            oldest_pr: "3 days ago",
          },
          {
            application_name: "content-tagger",
            application_url: "https://github.com/alphagov/content-tagger?q=is:pr+is:open+label:dependencies",
            pull_request_count: 2,
            oldest_pr: "3 days ago",
          },
        ],
      }

      result = described_class.new.execute(applications_by_team: applications_by_team)

      expect(result).to eq('<https://govuk-dependencies.herokuapp.com/team/taxonomy|taxonomy> have 3 Dependabot PRs open on the following apps:

<https://github.com/alphagov/collections-publisher/pulls?q=is:pr+is:open+label:dependencies|collections-publisher> (1, opened 3 days ago)
<https://github.com/alphagov/content-tagger/pulls?q=is:pr+is:open+label:dependencies|content-tagger> (2, oldest one opened 3 days ago)')
    end
  end
end
