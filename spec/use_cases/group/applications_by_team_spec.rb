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
      pull_request_1 = {
        application_name: "some-application",
        title: "Some title",
        opened_at: Date.today,
        open_since: "today",
        url: "http://foo.com",
      }
      pull_request_2 = {
        application_name: "some-application",
        title: "Some title",
        opened_at: Date.parse("2022-08-15"),
        open_since: "3 days ago",
        url: "http://foo.com",
      }

      team = {
        team_name: "Some Team",
        applications: %w[some-application],
      }

      result = subject.execute(pull_requests: [pull_request_1, pull_request_2], teams: [team])
      expected_result = [
        {
          team_name: "Some Team",
          applications:
          [
            {
              application_name: "some-application",
              application_url:
              "https://github.com/alphagov/some-application/pulls?q=is:pr+is:open+label:dependencies",
              pull_request_count: 2,
              oldest_pr: "3 days ago",
              opened_at: "2022-08-15",
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
        open_since: "today",
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
        open_since: "today",
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
              oldest_pr: "today",
              opened_at: Date.today.to_date.to_s,
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
                      oldest_pr: "today",
                      opened_at: Date.today.to_date.to_s,
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
        open_since: "today",
        url: "http://foo.com",
      }

      pull_request_frontend2 = {
        application_name: "collections",
        title: "bump rspec from 1 to 2",
        opened_at: Date.today,
        open_since: "today",
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
              oldest_pr: "today",
              opened_at: Date.today.to_date.to_s,
            },
          ],
        },
      ]

      expect(result).to eq(expected_result)
    end
  end

  context "Given multiple applications and prs" do
    it "associates correctly and sorts by age/pr amount/alpha" do
      pull_request_1 = {
        application_name: "sheep-counter",
        title: "Some title",
        opened_at: Date.today,
        open_since: "today",
        url: "http://foo.com",
      }
      pull_request_2 = {
        application_name: "sheep-counter",
        title: "Some title",
        opened_at: Date.parse("2022-08-15"),
        open_since: "3 days ago",
        url: "http://foo.com",
      }
      pull_request_3 = {
        application_name: "apple-juicer",
        title: "Some title",
        opened_at: Date.today,
        open_since: "today",
        url: "http://foo.com",
      }
      pull_request_4 = {
        application_name: "potato-cleaner",
        title: "Some title",
        opened_at: Date.today,
        open_since: "today",
        url: "http://foo.com",
      }
      pull_request_5 = {
        application_name: "potato-cleaner",
        title: "Some title",
        opened_at: Date.today,
        open_since: "today",
        url: "http://foo.com",
      }
      pull_request_6 = {
        application_name: "potato-cleaner",
        title: "Some title",
        opened_at: Date.today,
        open_since: "today",
        url: "http://foo.com",
      }
      pull_request_7 = {
        application_name: "banana-peeler",
        title: "Some title",
        opened_at: Date.today,
        open_since: "today",
        url: "http://foo.com",
      }

      team = {
        team_name: "Some Team",
        applications: %w[sheep-counter apple-juicer potato-cleaner banana-peeler],
      }

      result = subject.execute(pull_requests: [pull_request_1, pull_request_2, pull_request_3, pull_request_4, pull_request_5, pull_request_6, pull_request_7], teams: [team])
      expected_result = [
        {
          team_name: "Some Team",
          applications:
          [
            {
              application_name: "sheep-counter",
              application_url:
              "https://github.com/alphagov/sheep-counter/pulls?q=is:pr+is:open+label:dependencies",
              pull_request_count: 2,
              oldest_pr: "3 days ago",
              opened_at: "2022-08-15",
            },
            {
              application_name: "potato-cleaner",
              application_url:
              "https://github.com/alphagov/potato-cleaner/pulls?q=is:pr+is:open+label:dependencies",
              pull_request_count: 3,
              oldest_pr: "today",
              opened_at: Date.today.to_date.to_s,
            },
            {
              application_name: "apple-juicer",
              application_url:
              "https://github.com/alphagov/apple-juicer/pulls?q=is:pr+is:open+label:dependencies",
              pull_request_count: 1,
              oldest_pr: "today",
              opened_at: Date.today.to_date.to_s,
            },
            {
              application_name: "banana-peeler",
              application_url:
              "https://github.com/alphagov/banana-peeler/pulls?q=is:pr+is:open+label:dependencies",
              pull_request_count: 1,
              oldest_pr: "today",
              opened_at: Date.today.to_date.to_s,
            },
          ],
        },
      ]
      expect(result).to eq(expected_result)
    end
  end
end
