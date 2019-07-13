# frozen_string_literal: true

require 'data_base/column.rb'

# add comment
module Column
  class String < Base

    def self.type
      ::String
    end

    def value_for(value)
      value.to_s
    end
  end
end
