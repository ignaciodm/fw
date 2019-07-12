# frozen_string_literal: true

class Aggregate
  #   include Clause

  def execute(records_grouped_by, aggregate_functions)
    records_grouped_by
      .map do |_key, records|
      sample = records.first
      aggregate_functions_executed = aggregate_functions.map do |aggregate_function_by_key|
        key = aggregate_function_by_key[:key]
        functions = aggregate_function_by_key[:functions]
        all_values_in_column = records.map(&key.to_sym)

        # TODO: logic should depend of field type
        result = {}
        result[key.to_sym] = functions.reduce(all_values_in_column) { |acc, f| acc.send(f.to_sym) }
        result
      end

      merged_attributes = [sample.to_h, aggregate_functions_executed].flatten.reduce do |merged, hash|
        [*merged, *hash].to_h
      end

      sample.class.new(*merged_attributes)
    end
  end
end
