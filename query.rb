# frozen_string_literal: true

require_relative 'lib/project_query_command_line.rb'

begin
  puts ProjectQueryCommandLine.run(ARGV.join(' '))
rescue StandardError => e
  puts e
end
