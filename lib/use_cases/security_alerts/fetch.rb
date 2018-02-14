module UseCases
  module SecurityAlerts
    class Fetch
      def initialize(
        fetch_gemfiles_use_case: UseCases::Gemfiles::Fetch.new,
        security_alert_gateway: Gateways::SecurityAlert.new
      )
        @fetch_gemfiles_use_case = fetch_gemfiles_use_case
        @security_alert_gateway = security_alert_gateway
      end

      def execute
        security_alerts_for_applications.compact
      end

    private

      attr_reader :security_alert_gateway, :fetch_gemfiles_use_case

      def applications
        fetch_gemfiles_use_case.execute.map { |gemfile| gemfile[:application_name] }.flatten
      end

      def security_alerts_for_applications
        applications.map do |application|
          alerts = security_alert_gateway.execute(application_name: application)
          next unless alerts.any?
          {
            application_name: application,
            alerts: alerts.map do |alert|
              {
                gem: alert.gem,
                criticality: alert.criticality,
                patched_versions: alert.patched_versions
              }
            end
          }
        end
      end
    end
  end
end
