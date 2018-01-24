source 'https://rubygems.org'

File.read('.ruby-version').chomp

gem 'sinatra'

group :production, :staging do
  gem 'unicorn'
end

group :development, :test do
  gem 'govuk-lint'
end

group :test do
  gem 'rspec', '~> 3.7.0'
end
