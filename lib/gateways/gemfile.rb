require 'open-uri'

module Gateways
  class Gemfile
    def execute(application_name:)
      open(gemfile_url(application_name)) do |gemfile_contents|
        Domain::Gemfile.new(file_contents: gemfile_contents.read)
      end
    end

  private

    ORGANIZATION = 'alphagov'.freeze

    def gemfile_url(application_name)
      "https://raw.githubusercontent.com/#{ORGANIZATION}/#{application_name}/master/Gemfile.lock"
    end
  end
end
