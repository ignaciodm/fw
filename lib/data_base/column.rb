# frozen_string_literal: true

# add comment
class Column
  attr_accessor :name, :type

  def initialize(name:, type:)
    @name = name
    @type = type
  end
end
