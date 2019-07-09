require 'table.rb'

class DataStore
   attr_accessor :tables
  
  def initialize
    @tables = {}
  end

  def create_table(model_class)
    table = Table.new(model: model_class) 
    yield(table)

    add_table_for_model(table, model_class)
    
    table
  end

  def store_record(model_class, data)
    table = table_for_model(model_class)
    table.add_record(data)
  end

  def table_for_model(model_class)
    @tables[model_class.to_s.downcase.to_sym]
  end

  def add_table_for_model(table, model_class)
    @tables[model_class.to_s.downcase.to_sym] = table
  end
  # def each_line_as_hash
  #   lower_case_columns = []

  #   File.open(@path, "r") do |f|
  #     f.each_with_index do |line, index|
  #       is_column_header_line = index == 0

  #       if is_column_header_line 
  #          @lower_case_columns = self.lower_case_columns(line)
  #       else 
  #         yield(build_line_hash(line))
  #       end
        
  #     end
  #   end
  # end

  # def lower_case_columns(line)
  #   line.split(separator).map(&:downcase).map(&:chomp)
  # end

  # def build_line_hash(line)
  #   line_values = line.split(separator).map(&:chomp)
  #   Hash[@lower_case_columns.zip(line_values)]
  # end
end
