# frozen_string_literal: true

require 'time'
require 'data_base/column.rb'

# add comment
module Column
  class Date < Base

    def self.type
      ::Date
    end

    def value_for(value)
      ::Date.parse(value)
    end
  end
end
