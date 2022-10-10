source "https://rubygems.org"

ruby File.read(".ruby-version").chomp

gem "activesupport"
gem "dalli"
gem "memcachier"
gem "octokit", "~> 5.6"
gem "rake", "~> 13.0.6"
gem "sinatra"
gem "slack-poster", "~> 2.2"
gem "vcr"

group :production, :staging do
  gem "unicorn"
end

group :development, :test do
  gem "rubocop-govuk"
end

group :test do
  gem "climate_control", "~> 1.2"
  gem "pry", "~> 0.14.1"
  gem "rack-test", "~> 2.0.2"
  gem "rspec", "~> 3.11.0"
  gem "timecop", "~> 0.9.5"
  gem "webmock"
end
