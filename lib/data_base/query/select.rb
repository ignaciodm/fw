# frozen_string_literal: true

class Select
  #   include Clause

  def execute(records, selected_columns)
    puts 'FILTERED_RECORDS SELECT'
    puts records.first.internal_bid
    puts records.first.internal_bid.class

    selected_columns = selected_columns.map(&:to_sym)
    records
      .map(&:to_query_result)
      .map { |query_result| query_result.slice(*selected_columns) }
  end
end
