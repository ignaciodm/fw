# frozen_string_literal: true

require_relative '../column.rb'

# add comment
module Column
  class String < Base
    def self.type
      ::String
    end

    def value_for(value)
      value.to_s
    end

    def is_valid?(value, options)
      return true unless options

      if options[:length]
        return false if value_casted_to_type(value).length > options[:length][:max]
      end

      true
    end
  end
end
