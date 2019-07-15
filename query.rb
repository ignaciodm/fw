# frozen_string_literal: true

require_relative 'lib/project_query_command_line.rb'

begin
  results = ProjectQueryCommandLine.run(ARGV.join(' '))
  puts"=========================="
  puts "==========Results========="
  puts "=========================="
  puts results

rescue InvalidArguments => e
  puts e
end
