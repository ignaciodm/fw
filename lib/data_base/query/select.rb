# frozen_string_literal: true

class Select
  #   include Clause

  def execute(records, selected_columns)
    if selected_columns
      selected_columns = selected_columns.map(&:to_sym)
      records
        .map(&:to_query_result)
        .map { |query_result| query_result.slice(*selected_columns) }
    else
      records.map(&:to_query_result)
    end
  end
end
