# frozen_string_literal: true

require 'time'
require 'data_base/column.rb'

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
    @columns << Column.new(type: type, name: name.to_s)
  end

  def add_record(record)
    @records << record # add validation
  end

  def on_each_record_with_index
    records.each_with_index { |record, index| yield(record, index) }
  end

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

  def remove_record_by_index(index)
    records.slice!(index)
  end
end