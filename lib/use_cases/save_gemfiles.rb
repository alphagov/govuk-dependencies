module UseCases
  class SaveGemfiles
    def initialize(fetch_gemfiles:, file: Gateways::File)
      @fetch_gemfiles = fetch_gemfiles
      @file = file
    end

    def execute
      results = fetch_gemfiles.execute
      results.each do |result|
        save_gemfile(result.fetch(:application_name), result.fetch(:gemfile_contents))
      end
    end

  private

    attr_reader :fetch_gemfiles, :file

    def save_gemfile(application_name, file_contents)
      gemfile_path = "tmp/#{application_name}_gemfile.lock"

      file.write(gemfile_path, file_contents)
    end
  end
end
