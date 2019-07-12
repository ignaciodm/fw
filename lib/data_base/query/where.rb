# frozen_string_literal: true

class Where
  #   include Clause

  def execute(records, conditions)
    records.filter do |record|
      # assuming only conditions with = operator. not contemplating >, <, >=
      conditions.all? do |column, value|
        record.send(column) == record.class.value_for(column, value)
      end
    end
  end
end
