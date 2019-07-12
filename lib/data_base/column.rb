# frozen_string_literal: true

require 'time'
# add comment
class Column
  attr_accessor :name, :type

  def initialize(name:, type:)
    @name = name
    @type = type
  end

  def value_casted_to_type(value)
    return value unless value.is_a?(String)

    case type.to_s
    when 'Date'
      Date.parse(value)
    when 'Time'
      Time.parse(value)
    when 'Float'
      value.to_f
    when 'Integer'
      value.to_i
    else
      value
    end
  end
end
