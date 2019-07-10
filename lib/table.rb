# frozen_string_literal: true

require 'column.rb'

class Table
  attr_accessor :name, :model_class, :columns, :records, :indexes, :index_hash

  def initialize(model: model)
    @name = model.to_s.downcase
    @model_class = model
    @columns = []
    @records = []
    @indexes = []
    @index_hash = {}
  end

  def add_column(type, name)
    @columns << Column.new(type: type, name: name.to_s)
  end

  def add_record(record)
    new_record = @model_class.new(*record)

    @records << new_record # add validation

    # TODO: , do this for each index in @indexes
    added_record_index = @records.size - 1
    index_key = @indexes.first[:keys].map do |key|
      new_record.send(key.to_sym)
    end.join('.')

    @index_hash[index_key] = added_record_index
  end

  def add_combined_index(*keys, options)
    @indexes << { keys: keys, options: options } # TODO: create model for index?
  end

  def string(name)
    add_column String, name
  end

  def integer(name)
    add_column Integer, name
  end
end
