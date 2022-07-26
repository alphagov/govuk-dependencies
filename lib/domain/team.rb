module Domain
  class Team
    attr_reader :team_name, :applications

    def initialize(team_name:, applications:)
      @team_name = team_name
      @applications = applications
    end
  end
end
