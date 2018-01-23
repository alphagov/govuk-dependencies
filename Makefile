serve:
	bundle exec rackup

test:
	bundle exec rspec

lint:
	bundle exec govuk-lint-ruby

build: lint test
