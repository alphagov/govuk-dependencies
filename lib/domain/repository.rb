module Domain
  class Repository
    attr_reader :name, :url

    def initialize(name:, url:)
      @name = name
      @url = url
    end
  end
end
