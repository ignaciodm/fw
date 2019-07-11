# frozen_string_literal: true

class Index
  attr_accessor :keys, :options, :table

  def initialize(keys:, options:)
    @keys = keys
    @options = options
    @table = {}
  end

  def update_with(table)
      table.on_each_record_with_index do |record, index| 
        key = key_for_record(record)
        self.table[key] = index
      end
  end

  def key_for_record(record)
    keys
      .map { |key| record.send(key.to_sym) }
      .join('.')
  end

  def validate(record)
    !is_unique?(record)
  end

  def is_unique?(record)
    !index_for_record(record)
  end

  def index_for_record(record)
    table[key_for_record(record)]
  end

end
