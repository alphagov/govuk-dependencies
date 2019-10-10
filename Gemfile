source "https://rubygems.org"

ruby File.read(".ruby-version").chomp

gem "bundler-audit", git: "https://github.com/rubysec/bundler-audit", branch: "master"
gem "octokit", "~> 4.3"
gem "rake", "~> 12.3.0"
gem "sinatra"
gem "slack-poster", "~> 2.2"

group :production, :staging do
  gem "unicorn"
end

group :development, :test do
  gem "govuk-lint"
end

group :test do
  gem "climate_control", "~> 0.2"
  gem "pry", "~> 0.11.3"
  gem "rack-test", "~> 0.8.0"
  gem "rspec", "~> 3.7.0"
  gem "timecop", "~> 0.9.1"
  gem "vcr"
  gem "webmock"
end
