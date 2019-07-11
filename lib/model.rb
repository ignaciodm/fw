# frozen_string_literal: true

# add comment
module Model
  def to_key
    to_s.downcase.to_sym
  end
end
