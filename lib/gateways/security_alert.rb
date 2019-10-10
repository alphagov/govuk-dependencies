require "bundler/audit/scanner"

module Gateways
  class SecurityAlert
    def execute(application_name:)
      scanner = Bundler::Audit::Scanner.new("tmp/", gemfile_path(application_name))
      unpatched_gems = scanner.scan.select { |result| result.is_a?(Bundler::Audit::Scanner::UnpatchedGem) }
      alerts_with_criticality = unpatched_gems.select { |gem| gem.advisory.criticality }
      alerts_with_criticality.map do |alert|
        Domain::SecurityAlert.new(
          gem: alert.gem.name,
          criticality: alert.advisory.criticality.to_s,
          patched_versions: alert.advisory.patched_versions.first.to_s,
        )
      end
    end

  private

    def gemfile_path(application_name)
      "#{application_name}_gemfile.lock"
    end
  end
end
