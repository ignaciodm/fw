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

    def is_valid?(value, options)
      puts 'options'
      puts options.class
      return true unless options

      if options[:length]
        
        puts options[:length][:max] 
        puts value_casted_to_type(value).length
        if value_casted_to_type(value).length > options[:length][:max] 
          return false
        end
      end

      true
    end
  end
end
