def add_commas(number)
  number_parts = sprintf('%.2f',number).split(/\./)
  front = number_parts[0].reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
  [front, number_parts[1]].join('.')
end

class Numeric
  def usd
    "$" + add_commas(self)
  end

  def pct
    add_commas(self * 100.0) + "%"
  end
end

module FloatInterface
  def initialize(number)
    @number = number
  end

  def coerce(val)
    [val, @number]
  end

  def <=>(val); @number<=>val;  end
  def >(val);   @number>val;    end
  def <(val);   @number<val;    end
  def ==(val);  @number==val;   end
  def -(val); @number - val; end
  def +(val); @number + val; end
end

class Dollar
  include FloatInterface

  def to_s
    @number.usd
  end
end

class Rate
  include FloatInterface

  def to_s
    @number.pct
  end
end