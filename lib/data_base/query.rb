# frozen_string_literal: true

require_relative 'query/aggregate.rb'
require_relative 'query/group_by.rb'
require_relative 'query/order_by.rb'
require_relative 'query/select.rb'
require_relative 'query/where.rb'

# add comment
class Query
  attr_accessor :table,
                :where_conditions,
                :select_columns,
                :sort_by_columns,
                :group_by_columns,
                :aggregate_functions,
                :from_model_class

  CLAUSES = {
    where: {
      execute: proc { |records, query| Where.new.execute(records, query.where_conditions) },
      if: proc { |query| query.where_conditions }
    },
    group_by: {
      execute: proc { |records, query| GroupBy.new.execute(records, query.group_by_columns) },
      if: proc { |query| query.group_by_columns }
    },
    aggregate: {
      execute: proc do |records, query|
                 Aggregate.new.execute(records, query.aggregate_functions)
               end,
      if: proc { |query| query.aggregate_functions && !query.aggregate_functions.empty? }
    },
    order_by: {
      execute: proc { |records, query| OrderBy.new.execute(records, query.sort_by_columns) },
      if: proc { |query| query.sort_by_columns }
    },
    select: {
      execute: proc { |records, query| Select.new.execute(records, query.select_columns) },
      if: proc { |_query| true }
    }
  }.freeze

  def select(columns)
    build_select_columns(columns)
    build_aggregate_functios(columns)
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

  def group_by(columns)
    @group_by_columns = columns
    self
  end

  def from(model_class)
    @table = model_class.table
    self
  end

  def run
    CLAUSES.values.reduce(@table.records) do |filtered_records, clause|
      if clause[:if].call(self)
        clause[:execute].call(filtered_records, self)
      else
        filtered_records
      end
    end
  end

  private

  def build_select_columns(columns)
    return unless columns

    @select_columns = columns.map { |column| column.split(':').first }
  end

  def build_aggregate_functios(columns)
    return unless columns

    @aggregate_functions = columns.map do |column|
      key, *functions = column.split(':')
      functions.empty? ? nil : { key: key, functions: functions }
    end.compact
  end
end
