# frozen_string_literal: true

# add comment
class Query
  attr_accessor :schema,
                :table,
                :where_conditions,
                :select_columns,
                :sort_by_columns,
                :group_by_columns,
                :aggregate_functions,
                :from_model_class

  CLAUSES = {
    SELECT: proc do |records, columns|
      puts 'FILTERED_RECORDS SELECT'
      puts records.first.internal_bid
      puts records.first.internal_bid.class
      records.map(&:to_query_result).map do |record|
        columns_to_return = {}
        columns.each do |column|
          # this seems wrong. Logic should be unified for one type.
          # Instead of Hash, or Project Model, consider creating Result entity
          columns_to_return[column.to_sym] = record[column.to_sym]
          #   columns_to_return[column.to_sym] = record.send(column.to_sym)
        end
        columns_to_return
      end
    end,
    WHERE: proc do |records, conditions|
      #   puts '=============conditions'
      #   puts conditions
      records.filter do |record|
        # assuming only conditions with = operator. not contemplating >, <, >=
        conditions.all? do |column, value|
          # TODO: consider evaluating value in the context
          # of a column type (date, text, timestamp, etc)

          record.send(column) == record.class.value_for(column, value)
        end
      end
    end,
    ORDER_BY: proc do |records, columns|
      #   puts '=============order'
      #   puts columns
      records.sort_by do |record|
        sort_by_values = columns.map { |column| record.send(column.to_sym) }
        sort_by_values
      end
    end,
    GROUP_BY: proc do |records, columns|
      #   puts '=============group'
      #   puts columns
      column = columns.first # TODO: just one column for now
      records.group_by(&column.to_sym)
    end,
    AGGREGATE: proc do |records_grouped_by, aggregate_functions|
      puts '=============AGGREGATE'
      puts aggregate_functions
      #   puts records_grouped_by

      records_grouped_by
        .map do |_key, records|
          sample = records.first
          aggregate_functions_executed = aggregate_functions.map do |aggregate_function_by_key|
            # puts aggregate_function_by_key
            # puts 'aggregate_function_by_key'
            key = aggregate_function_by_key[:key]
            functions = aggregate_function_by_key[:functions]
            all_values_in_column = records.map(&key.to_sym)

            # TODO: logic should depend of field type
            result = {}
            result[key.to_sym] = functions.reduce(all_values_in_column) { |acc, f| acc.send(f.to_sym) }
            result
          end

          puts '.................................sample'
          puts sample

          merged_attributes = [sample.to_h, aggregate_functions_executed].flatten.reduce do |merged, hash|
            [*merged, *hash].to_h
            # *op1.to_h, *op2.to_h].to_h
          end

          sample.class.new(*merged_attributes)
        end
    end
  }.freeze

  def initialize(schema)
    @schema = schema
  end

  def select(columns)
    @select_columns = columns.map { |column| column.split(':').first }

    @aggregate_functions = columns.map do |column|
      key, *functions = column.split(':')
      functions.empty? ? nil : { key: key, functions: functions }
    end
                                  .compact

    # puts '=============AGGREGATE'
    # puts aggregate_functions

    self
  end

  def where(conditions)
    @where_conditions = conditions
    self
  end

  def order_by(columns)
    @sort_by_columns = columns
    self
  end

  def group_by(columns)
    @group_by_columns = columns
    self
  end

  def from(model_class)
    @table = schema[model_class.to_key].table
    self
  end

  def run
    filtered_records = @table.records

    puts 'FILTERED_RECORDS'
    puts filtered_records.first
    puts filtered_records.first.internal_bid
    puts filtered_records.first.internal_bid.class

    if @where_conditions
      filtered_records = CLAUSES[:WHERE].call(filtered_records, @where_conditions)
    end

    puts 'FILTERED_RECORDS WHERE'
    puts filtered_records.first
    puts filtered_records.first.internal_bid
    puts filtered_records.first.internal_bid.class

    if @group_by_columns
      filtered_records = CLAUSES[:GROUP_BY].call(filtered_records, @group_by_columns)
    end

    puts 'FILTERED_RECORDS GROUP-BY'
    # puts filtered_records.first.first
    # puts filtered_records.first.values.first.internal_bid
    # puts filtered_records.first.values.first.internal_bid.class

    if @aggregate_functions && !@aggregate_functions.empty?
      filtered_records = CLAUSES[:AGGREGATE].call(filtered_records, @aggregate_functions)
    end

    puts 'FILTERED_RECORDS AGGREGATE'
    puts filtered_records.first
    puts filtered_records.first.internal_bid
    puts filtered_records.first.internal_bid.class

    if @sort_by_columns
      filtered_records = CLAUSES[:ORDER_BY].call(filtered_records, @sort_by_columns)
    end

    puts 'FILTERED_RECORDS ORDER_BY'
    puts filtered_records.first
    puts filtered_records.first.internal_bid
    puts filtered_records.first.internal_bid.class

    filtered_records = CLAUSES[:SELECT].call(filtered_records, @select_columns) if @select_columns

    puts 'FILTERED_RECORDS SELECT'
    puts filtered_records.first
    # puts filtered_records.first.internal_bid
    # puts filtered_records.first.internal_bid.class

    filtered_records
  end
end
