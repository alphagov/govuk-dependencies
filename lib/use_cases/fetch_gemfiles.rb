module UseCases
  class FetchGemfiles
    def initialize(gemfile_gateway: Gateways::Gemfile.new)
      @gemfile_gateway = gemfile_gateway
    end

    def execute(application_names:)
      application_names.map do |application_name|
        result = gemfile_gateway.execute(application_name: application_name)

        {
          application_name: application_name,
          gemfile_contents: result.file_contents
        }
      end
    end

  private

    attr_reader :gemfile_gateway
  end
end
