require_relative 'dependaseal'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
rescue LoadError
  p 'Could not load RSpec'
end

task :dependaseal do
  Dependaseal.new.execute
end
