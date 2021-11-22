source "https://rubygems.org"

ruby File.read(".ruby-version").chomp

gem "dalli"
gem "memcachier"
gem "octokit", "~> 4.3"
gem "rake", "~> 12.3.0"
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
  gem "climate_control", "~> 0.2"
  gem "pry", "~> 0.11.3"
  gem "rack-test", "~> 1.1.0"
  gem "rspec", "~> 3.10.0"
  gem "timecop", "~> 0.9.1"
  gem "webmock"
end
