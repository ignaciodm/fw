# frozen_string_literal: true

require_relative 'model_class_methods.rb'

# add comment
module Model
  def self.included(base)
    base.extend(ModelClassMethods)
  end

  def initialize(*args)
    args.each do |key, v|
      value = self.class.value_for(key, v)
      instance_variable_set("@#{key}", value) unless v.nil?
    end
  end

  def validate!
    # true
    self.class.run_validations(self)
  end
end
