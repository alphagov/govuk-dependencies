module UseCases
  module Distribute
    class OverflowToDevelopersChannel
      def execute(application_prs_by_team:, overflow_at: 15)
        @application_prs_by_team = application_prs_by_team
        @overflow_at = overflow_at

        redistribution = []

        application_prs_by_team.each do |application_prs_for_team|
          redistribution.concat(redistribute(application_prs_for_team[:applications]))
        end

        if redistribution.any?
          ensure_govuk_developers_exists
          govuk_developers_application_prs[:applications].concat(redistribution)
        end

        application_prs_by_team
      end

    private

      attr_reader :application_prs_by_team, :overflow_at

      def ensure_govuk_developers_exists
        unless govuk_developers_application_prs
          application_prs_by_team << { team_name: "govuk-developers", applications: [] }
        end
      end

      def redistribute(applications_with_prs)
        return [] if applications_with_prs.count <= overflow_at

        number_of_apps = applications_with_prs.count
        applications_with_prs.pop(number_of_apps - overflow_at)
      end

      def govuk_developers_application_prs
        application_prs_by_team.find { |h| h[:team_name] == "govuk-developers" }
      end
    end
  end
end
