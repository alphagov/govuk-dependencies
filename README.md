# govuk-dependencies

A tool for:
- Viewing all of the outstanding open pull requests made by Dependabot to GOV.UK repos
- Sending Slack messages to GDS Teams reminding them of open Dependabot PRs for their applications
- Viewing security alerts for old gems found in Gemfile.lock

## Screenshots

![screenshot](https://user-images.githubusercontent.com/976254/35578664-b0617926-05dc-11e8-9281-3b307a8792c4.png)

## Live examples

- [https://govuk-dependencies.herokuapp.com/](https://govuk-dependencies.herokuapp.com/)

## Technical documentation

This is a Sinatra application that uses the GitHub API in order to get a list of of PRs made
by Dependabot and groups them in various ways:

- By application
- By team
- By gem

### Dependencies

- [octokit/octokit.rb](https://github.com/octokit/octokit.rb) - Used for interacting with the GitHub API
- [bundler-audit](https://github.com/rubysec/bundler-audit) - Security scanner for identifying CVEs

### Running the application

`bundle exec rackup`

Running this will start your application at [localhost:9292](localhost:9292)

### Running the test suite

`bundle exec rake`

### Environment variables

- `GITHUB_TOKEN` - OAuth token generated on GitHub which does not require any special permissions
  - Used to interact with the GitHub API, although not required it will help avoid limiting
- `SLACK_WEBHOOK_URL` - The webhook URL for sending Slack messages to
- `DEPENDAPANDA_SECRET` - Secret token for manually requesting Slack messages

### Rate limiting

If you find yourself being rate limited by GitHub - you can define the `GITHUB_TOKEN` environment variable.
This needs to be a token generated from GitHub, however as the repositories are all public it needs no special
permissions.

### Security Alerts

![screenshot](https://user-images.githubusercontent.com/1215147/36216867-e2141466-11a7-11e8-8511-7a8942b55395.png)

When navigating to the security alerts page (`/security-alerts`) it will update the local advisory-db copy, download, and save the
gemfiles for every ruby project defined within [apps.json](docs.publishing.service.gov.uk/apps.json).

#### Gemfiles

When downloading gemfiles for each application when checking for security alerts, they can be found within `tmp/{application_name}_gemfile.lock`

#### Advisory DB

The security alerts feature works by using [bundler-audit](https://github.com/rubysec/bundler-audit) which relies on having
a local copy of the [ruby-advisory-db](https://github.com/rubysec/ruby-advisory-db/). Without this, the security alerts page
will show that there are no security alerts even if some exist.

To update this database you can run:

`bundle exec rake update_advisory_db`

Additionally, to update this within code you can run:

`Bundler::Audit::Database.update!`

