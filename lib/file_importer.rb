# frozen_string_literal: true

class FileImporter
  attr_accessor :path, :separator

  def initialize(path: path, separator: separator)
    @path = path
    @separator = separator
  end

  def lines_as_hash
    lines = []
    each_line_as_hash { |hash| lines << hash }
    lines
  end

  def each_line_as_hash
    lower_case_columns = []

    File.open(@path, 'r') do |f|
      f.each_with_index do |line, index|
        is_column_header_line = index == 0

        if is_column_header_line
          @lower_case_columns = self.lower_case_columns(line)
        else
          yield(build_line_hash(line))
        end
      end
    end
  end

  def lower_case_columns(line)
    line.split(separator).map(&:downcase).map(&:chomp)
  end

  def build_line_hash(line)
    line_values = line.split(separator).map(&:chomp)
    Hash[@lower_case_columns.zip(line_values)]
  end
end
