module Domain
  class Team
    attr_reader :team_name, :applications, :continuously_deployed_apps

    def initialize(team_name:, applications:, continuously_deployed_apps:)
      @team_name = team_name
      @applications = applications
      @continuously_deployed_apps = continuously_deployed_apps
    end
  end
end
