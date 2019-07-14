# frozen_string_literal: true

class GroupBy
  def execute(records, columns)
    column = columns.first # TODO: just one column for now
    records.group_by(&column.to_sym)
  end
end
