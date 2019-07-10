module Model
  def to_key
    self.to_s.downcase.to_sym
  end
end
