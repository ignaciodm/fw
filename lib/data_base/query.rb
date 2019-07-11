# frozen_string_literal: true

# add comment
class Query
  attr_accessor :schema,
                :table,
                :where_conditions,
                :select_columns,
                :sort_by_columns,
                :from_model_class

  CLAUSES = {
    SELECT: proc do |records, columns|
      puts '=============table'
      puts records
      records.map do |record|
        columns_to_return = {}
        columns.each do |column|
          columns_to_return[column.to_sym] = record.send(column.to_sym)
        end
        columns_to_return
      end
    end,
    WHERE: proc do |records, conditions|
      puts '=============conditions'
      puts conditions
      records.filter do |record|
        # assuming only conditions with = operator. not contemplating >, <, >=
        conditions.all? do |column, value|
          # TODO: consider evaluating value in the context
          # of a column type (date, text, timestamp, etc)
          record.send(column) == value
        end
      end
    end,
    ORDER_BY: proc do |records, columns|
      puts '=============order'
      puts columns
      records.sort_by do |record|
        sort_by_values = columns.map { |column| record.send(column.to_sym) }
        puts '=============sort_by_values'
        puts sort_by_values
        sort_by_values
      end
    end
  }.freeze

  def initialize(schema)
    @schema = schema
  end

  def select(columns)
    @select_columns = columns
    self
  end

  def where(conditions)
    @where_conditions = conditions
    self
  end

  def order_by(columns)
    @sort_by_columns = columns
    self
  end

  def from(model_class)
    @table = schema[model_class.to_key].table
    self
  end

  def run
    filtered_records = @table.records

    if @where_conditions
      filtered_records = CLAUSES[:WHERE].call(filtered_records, @where_conditions)
    end

    if @sort_by_columns
      filtered_records = CLAUSES[:ORDER_BY].call(filtered_records, @sort_by_columns)
    end

    filtered_records = CLAUSES[:SELECT].call(filtered_records, @select_columns) if @select_columns

    filtered_records
  end
end
