# frozen_string_literal: true

require 'table.rb'
require 'index.rb'
require 'ostruct'

class DataStore
  attr_accessor :schema, :index_hash

  def initialize
    @schema = OpenStruct.new
    @index_hash = {}
  end

  def create_table(model_class)
    table = Table.new(model: model_class)
    yield(table)

    add_table_for_model(table, model_class)

    table
  end

  def add_index(model_class, keys, opts)
    on_schema_context_for_model(model_class) do |context|
      context.indexes << Index.new(keys: keys, options: opts) # TODO create Index model
    end
  end

  def store_record(model_class, data)
    on_schema_context_for_model(model_class) do |context|
      new_record = model_class.new(*data)
      table = context.table
      primary_index = context.indexes.first # todo identify is unique index

      table.remove_record_by_index(primary_index.index_for_record(new_record)) unless primary_index.is_unique?(new_record)

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
