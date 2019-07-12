# frozen_string_literal: true

require 'data_base/table.rb'
require 'data_base/index.rb'
require 'data_base/query.rb'
require 'ostruct'

# add comment
class Store
  attr_accessor :schema

  def initialize
    @schema = OpenStruct.new
  end

  def create_table(model_class)
    table = Table.new(model: model_class)
    model_class.table = table
    yield(table)

    add_table_for_model(table, model_class)

    table
  end

  def add_index(model_class, keys, opts)
    on_schema_context_for_model(model_class) do |context|
      context.indexes << Index.new(keys: keys, options: opts)
    end
  end

  def new_query
    Query.new
  end

  def store_record(model_class, data)
    on_schema_context_for_model(model_class) do |context|
      new_record = model_class.new(*data)
      table = context.table
      primary_index = context.indexes.first # TODO: identify is unique index

      if primary_index && !primary_index.unique?(new_record)
        table.remove_record_by_index(primary_index.index_for_record(new_record))
      end

      table.add_record(new_record)

      primary_index.update_with(table)
    end
  end

  private

  # def on_table_for_model(model_class)
  #    on_schema_for_model(model_class) { |model| yield(model) }
  # end

  def on_schema_context_for_model(model_class)
    @schema[model_class.to_key] ||= OpenStruct.new
    yield(@schema[model_class.to_key])
  end

  def add_table_for_model(table, model_class)
    @schema[model_class.to_key] = OpenStruct.new(table: table, indexes: [])
  end
end
