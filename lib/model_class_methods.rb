# frozen_string_literal: true

# add comment
module ModelClassMethods
  def table
    @@table
  end

  def table=(table)
    @@table = table
  end

  def to_key
    to_s.downcase.to_sym
  end

  def value_for(key, value)
    table.value_casted_to_column_type(key, value)
  end
end
