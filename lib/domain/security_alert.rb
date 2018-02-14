module Domain
  class SecurityAlert
    attr_reader :gem, :criticality, :patched_versions

    def initialize(gem:, criticality:, patched_versions:)
      @gem = gem
      @criticality = criticality
      @patched_versions = patched_versions
    end
  end
end
