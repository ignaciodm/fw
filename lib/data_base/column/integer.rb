# frozen_string_literal: true

require 'data_base/column.rb'

# add comment
module Column
  class Integer < Base

    def self.type
      ::Integer
    end

    def value_for(value)
      value.to_i
    end
  end
end
