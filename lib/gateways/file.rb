module Gateways
  class File
    def write(path, content)
      ::File.open(path, "w") { |f| f.write(content) }
    end
  end
end
