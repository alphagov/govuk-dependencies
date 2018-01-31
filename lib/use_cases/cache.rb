module UseCases
  class Cache
    def initialize(path:, file: File)
      @path = path
      @file = file
    end

    def execute
      return cached if fresh_cache?

      result = yield
      file.open(path, 'w') { |f| f.write(result) }

      result
    end

  private

    CACHE_DURATION_SECONDS = 120

    attr_reader :path, :file

    def cached
      file.read(path)
    end

    def fresh_cache?
      file.exists?(path) && file.mtime(path) > (Time.now.utc - CACHE_DURATION_SECONDS)
    end
  end
end
