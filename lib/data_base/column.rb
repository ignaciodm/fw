# frozen_string_literal: true

# add comment
module Column
  class Base
    attr_accessor :name, :type

    def initialize(name:)
      @name = name
    end

    def value_casted_to_type(value)
      return value unless value.is_a?(::String)

      value_for(value)
    end

    def self.column_for(type, name)
      case type.to_s
      when 'Date'
        Column::Date.new(name: name.to_s)
      when 'Time'
        Column::Time.new(name: name.to_s)
      when 'Float'
        Column::Float.new(name: name.to_s)
      when 'Integer'
        Column::Integer.new(name: name.to_s)
      else
        Column::String.new(name: name.to_s)
      end
    end
  end
end

require_relative 'column/string.rb'
require_relative 'column/date.rb'
require_relative 'column/time.rb'
require_relative 'column/float.rb'
require_relative 'column/integer.rb'
