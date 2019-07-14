# frozen_string_literal: true

class Aggregate
  def execute_aggreated_functions(records, aggregate_functions)
    aggregate_functions.map do |by_key|
      key = by_key[:key]
      functions = by_key[:functions]
      all_values_in_column = records.map(&key.to_sym)

      result = {}
      result[key.to_sym] = functions.reduce(all_values_in_column) { |acc, f| acc.send(f.to_sym) }
      result
    end
  end

  def execute(records_grouped_by, aggregate_functions)
    records_grouped_by
      .map do |_key, records|
      sample = records.first

      aggregate_functions_executed = execute_aggreated_functions(records, aggregate_functions)

      merged_attributes = [sample.to_h, aggregate_functions_executed].flatten.reduce do |merged, hash|
        [*merged, *hash].to_h
      end

      sample.class.new(*merged_attributes)
    end
  end
end
