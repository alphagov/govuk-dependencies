module Domain
  class SecurityAlert
    attr_reader :gem, :criticality, :patched_versions

    def initialize(gem:, criticality:, patched_versions:)
      @gem = gem
      @criticality = criticality
      @patched_versions = patched_versions
    end

    def ==(other)
      other.class == self.class && other.state == state
    end

    alias_method :eql?, :==

    def hash
      state.hash
    end

  protected

    def state
      [gem, criticality, patched_versions]
    end
  end
end
