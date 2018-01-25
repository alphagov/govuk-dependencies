source 'https://rubygems.org'

File.read('.ruby-version').chomp

gem 'octokit', '~> 4.3'
gem 'sinatra'

group :production, :staging do
  gem 'unicorn'
end

group :development, :test do
  gem 'govuk-lint'
end

group :test do
  gem 'rack-test', '~> 0.8.0'
  gem 'rspec', '~> 3.7.0'
  gem 'timecop', '~> 0.9.1'
  gem 'webmock', '~> 3.3.0'
end
