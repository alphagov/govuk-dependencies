module UseCases
  class Cache
    def initialize(path:, file: File)
      @path = path
      @file = file
    end

    def execute(cache_duration_seconds: 120)
      return cached if fresh_cache?(cache_duration_seconds)

      result = yield
      file.open(path, 'w') { |f| f.write(result) }

      result
    end

  private

    attr_reader :path, :file

    def cached
      file.read(path)
    end

    def fresh_cache?(cache_duration_seconds)
      file.exists?(path) && file.mtime(path) > (Time.now.utc - cache_duration_seconds)
    end
  end
end
