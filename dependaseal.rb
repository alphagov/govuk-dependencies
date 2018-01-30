require_relative 'lib/loader'

class Dependaseal
  def execute
    UseCases::SendSlackMessages.new.execute
  end
end
