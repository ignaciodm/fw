# frozen_string_literal: true

module Model
  def to_key
    to_s.downcase.to_sym
  end
end
