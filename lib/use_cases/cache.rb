module UseCases
  class Cache
    def initialize(name:, file: File)
      @name = Dir.pwd + "/public/cache/#{name}.html"
      @file = file
    end

    def execute(&block)
      if fresh_cache?
        file.read(name)
      else
        html = block.call
        file.open(name, 'w') { |f| f.write(html) }

        html
      end
    end

    private

    CACHE_DURATION_SECONDS = 120

    attr_reader :name, :file

    def fresh_cache?
      file.exists?(name) && file.mtime(name) > (Time.now.utc - CACHE_DURATION_SECONDS)
    end
  end
end
