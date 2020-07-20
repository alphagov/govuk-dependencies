describe UseCases::Group::ApplicationsByTeam do
  context "Given no teams or pull request" do
    it "returns an empty list" do
      expect(
        subject.execute(pull_requests: [], teams: []),
      ).to be_empty
    end
  end

  context "Given a pull request and a team" do
    it "associates one pull request to one team" do
      pull_request = {
        application_name: "some-application",
        title: "Some title",
        opened_at: Date.today,
        url: "http://foo.com",
      }

      team = {
        team_name: "Some Team",
        applications: %w[some-application],
      }

      result = subject.execute(pull_requests: [pull_request], teams: [team])
      expected_result = [
        {
          team_name: "Some Team",
          applications:
          [
            {
              application_name: "some-application",
              application_url:
              "https://github.com/alphagov/some-application/pulls?q=is:pr+is:open+label:dependencies",
              pull_request_count: 1,
            },
          ],
        },
      ]

      expect(result).to eq(expected_result)
    end
  end

  context "Given a pull requests for multiple teams" do
    it "associates all the teams with their pull requests" do
      pull_request_frontend = {
        application_name: "collections",
        title: "bump x to y",
        opened_at: Date.today,
        url: "http://foo.com",
      }

      team_frontend = {
        team_name: "frontend-design",
        applications: %(collections),
      }

      pull_request_taxonomy = {
        application_name: "collections-publisher",
        title: "bump x to y",
        opened_at: Date.today,
        url: "http://foo.com",
      }

      team_taxonomy = {
        team_name: "taxonomy",
        applications: %w[collections-publisher],
      }

      result = subject.execute(pull_requests: [pull_request_frontend, pull_request_taxonomy], teams: [team_frontend, team_taxonomy])
      expected_result = [
        {
          team_name: "frontend-design",
          applications:
          [
            {
              application_name: "collections",
              application_url:
              "https://github.com/alphagov/collections/pulls?q=is:pr+is:open+label:dependencies",
              pull_request_count: 1,
            },
          ],
        },
        {
          team_name: "taxonomy",
          applications:
                  [
                    {
                      application_name: "collections-publisher",
                      application_url:
                      "https://github.com/alphagov/collections-publisher/pulls?q=is:pr+is:open+label:dependencies",
                      pull_request_count: 1,
                    },
                  ],
        },
      ]

      expect(result).to eq(expected_result)
    end
  end

  context "Sums the pull request count" do
    it "associates all the teams with their pull requests" do
      pull_request_frontend = {
        application_name: "collections",
        title: "bump x to y",
        opened_at: Date.today,
        url: "http://foo.com",
      }

      pull_request_frontend2 = {
        application_name: "collections",
        title: "bump rspec from 1 to 2",
        opened_at: Date.today,
        url: "http://foo.com",
      }

      team_frontend = {
        team_name: "frontend-design",
        applications: %(collections),
      }

      result = subject.execute(pull_requests: [pull_request_frontend, pull_request_frontend2], teams: [team_frontend])

      expected_result = [
        {
          team_name: "frontend-design",
          applications:
          [
            {
              application_name: "collections",
              application_url:
              "https://github.com/alphagov/collections/pulls?q=is:pr+is:open+label:dependencies",
              pull_request_count: 2,
            },
          ],
        },
      ]

      expect(result).to eq(expected_result)
    end
  end
end
