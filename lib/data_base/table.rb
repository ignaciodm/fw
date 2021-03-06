# frozen_string_literal: true

require 'time'
require_relative 'column.rb'

# add comment
class Table
  attr_accessor :name, :model_class, :columns, :records

  def initialize(model:)
    @name = model.to_s.downcase
    @model_class = model
    @columns = []
    @records = []
  end

  def add_column(type, name)
    @columns << Column::Base.column_for(type, name)
  end

  def add_record(record)
    record.validate!
    @records << record
  end

  def on_each_record_with_index
    records.each_with_index { |record, index| yield(record, index) }
  end

  def remove_record_by_index(index)
    records.slice!(index)
  end

  def value_casted_to_column_type(key, value)
    column = column_for(key)
    column.value_casted_to_type(value)
  end

  # TODO: make these methdos generic instread of repeating logic
  # use define_method, or hash value references
  def string(name)
    add_column String, name
  end

  def integer(name)
    add_column Integer, name
  end

  def float(name)
    add_column Float, name
  end

  def date(name)
    add_column Date, name
  end

  def timestamp(name)
    add_column Time, name
  end

  def column_for(key)
    columns.find { |c| c.name.to_sym == key.to_sym }
  end
end
