# frozen_string_literal: true

require 'time'
require 'data_base/column.rb'

# add comment
module Column
  class Time < Base

    def self.type
      ::Time
    end

    def value_for(value)
      ::Time.parse(value)
    end
  end
end
