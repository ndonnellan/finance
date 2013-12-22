class Object
  def to_pct_str(format)
    unless self.class == Fixnum || self.class == Float
      raise "to_pct_str is not supported for #{self.class}"
    end

    n_str = sprintf format, self
    if self >= 0
      "+" + n_str
    else
      n_str
    end
  end

  def usd
    Usd.new(self)
  end
end