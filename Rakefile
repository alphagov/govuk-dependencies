require_relative 'dependapanda'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
rescue LoadError
  p 'Could not load RSpec'
end

task :dependapanda do
  Dependapanda.new.send_simple_message
end

task :dependapanda_loud do
  Dependapanda.new.send_full_message
end
