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

    attr_reader :name, :file

    def fresh_cache?
      file.exists?(name) && file.mtime(name) > (Time.now.utc - 120)
    end
  end
end
