module UseCases
  class ViewCacher
    def initialize(cache_file:, file: File)
      @cache_file = Dir.pwd + "/public/cache/#{cache_file}.html"
      @file = file
    end

    def execute(&block)
      if fresh_cache?
        file.read(cache_file)
      else
        html = block.call
        file.open(cache_file, 'w') { |f| f.write(html) }

        html
      end
    end

    private

    attr_reader :cache_file, :file

    def fresh_cache?
      file.exists?(cache_file) && file.mtime(cache_file) > (Time.now.utc - 120)
    end
  end
end
