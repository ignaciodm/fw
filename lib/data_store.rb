# frozen_string_literal: true

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
    @tables[model_class.to_key]
  end

  def add_table_for_model(table, model_class)
    @tables[model_class.to_key] = table
  end
end
