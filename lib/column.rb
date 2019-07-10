# frozen_string_literal: true

class Column
  attr_accessor :name, :type

  def initialize(name:, type: )
    @name = name
    @type = type
  end
end
