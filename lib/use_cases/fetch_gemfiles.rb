module UseCases
  class FetchGemfiles
    def initialize(gemfile_gateway: Gateways::Gemfile.new,
                   teams_use_case: UseCases::FetchTeams.new)
      @gemfile_gateway = gemfile_gateway
      @teams_use_case = teams_use_case
    end

    def execute
      gemfiles_for_applications.compact
    end

  private

    attr_reader :gemfile_gateway, :teams_use_case

    def gemfiles_for_applications
      application_names.map do |application_name|
        result = gemfile_gateway.execute(application_name: application_name)

        next if result.nil?
        {
          application_name: application_name,
          gemfile_contents: result.file_contents
        }
      end
    end

    def application_names
      teams_use_case.execute.map { |team| team[:applications] }.flatten
    end
  end
end
