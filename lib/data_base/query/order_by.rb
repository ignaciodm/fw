# frozen_string_literal: true

class OrderBy
  #   include Clause

  def execute(records, columns)
    records.sort_by do |record|
      sort_by_values = columns.map { |column| record.send(column.to_sym) }
      sort_by_values
    end
  end
end
