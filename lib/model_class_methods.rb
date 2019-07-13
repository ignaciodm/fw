# frozen_string_literal: true

class RecordInvalid < StandardError
  def initialize(msg="My default message")
    super
  end
end

# add comment
module ModelClassMethods

  @@validations = []

  def table
    @@table
  end

  def table=(table)
    @@table = table
  end

  def validations
    @@validations
  end

  def add_validation(validation)
    self.validations << validation
  end

  def to_key
    to_s.downcase.to_sym
  end

  def value_for(key, value)
    table.value_casted_to_column_type(key, value)
  end

  def validate_attr(attr, *options) 

    validation = proc do |record|
      puts "-----------VALIDATION"
      puts "-----------ATTR"
      puts attr
      puts "-----------options"
      puts options
      puts options.class
      puts '"-----------table'
      puts table

      column = table.column_for(attr)
      puts '"-----------column'
      puts column

      column.is_valid?(record.send(attr), *options)
    end

    self.add_validation(validation)
  end
  
  def run_validations(model)
    validations.all? do |validation| 
      raise RecordInvalid, "#{model.class} not valid" if !validation.call(model)
       
      true
    end
  end
end
