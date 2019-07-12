# frozen_string_literal: true

class GroupBy
  #   include Clause

  def execute(records, columns)
    puts 'FILTERED_RECORDS SELECT'
    puts records.first.internal_bid
    puts records.first.internal_bid.class

    column = columns.first # TODO: just one column for now
    records.group_by(&column.to_sym)
  end
end
