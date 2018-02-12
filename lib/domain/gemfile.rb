module Domain
  class Gemfile
    attr_reader :file_contents

    def initialize(file_contents:)
      @file_contents = file_contents
    end
  end
end
