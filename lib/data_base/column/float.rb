# frozen_string_literal: true

require_relative '../column.rb'

# add comment
module Column
  class Float < Base
    def self.type
      ::Float
    end

    def value_for(value)
      value.to_f
    end
  end
end
