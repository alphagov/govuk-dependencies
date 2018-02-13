module Gateways
  class File
    def write(path, content)
      open(path, 'w') { |f| f.write(content) }
    end
  end
end
