# frozen_string_literal: true

class Where
  #   include Clause

  def execute(records, condition)
    
    records.filter do |record|
      condition.evaluate do |column, value, operator| 
        record.send(column) == record.class.value_for(column, value)
      end
    end
  end
end
