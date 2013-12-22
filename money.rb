class Class
  def dominant_number_method(*args)
    args.each do |method|
      class_eval %Q{
        def #{method}(val)
          if val.class <= CustomNumber
            self.class.new(@number #{method} val.number)
          elsif val.class <= Numeric
            self.class.new(@number #{method} val)
          else
            raise_coercion_exception(val.class)
          end
        end
      }
    end
  end

  def recessive_number_method(*args)
    args.each do |method|
      class_eval %Q{
        def #{method}(val)
          if val.class <= CustomNumber
            val.number #{method} @number
          elsif val.class <= Numeric
            self.class.new(@number #{method} val)
          else
            raise_coercion_exception(val.class)
          end
        end
      }
    end
  end

  def logical_method(*args)
    args.each do |method|
      class_eval %Q{
        def #{method}(val)
          if val.class <= CustomNumber
            @number #{method} val.number
          elsif val.class <= Numeric
            @number #{method} val
          else
            raise_coercion_exception(val.class)
          end
        end
      }
    end
  end
end

class CustomNumber
  logical_method :>, :<, :>=, :<=, :==

  def initialize(num)
    unless num.class <= Numeric
      raise "Cannot cast #{num.class} to #{self.class}"
    end

    @number = num
  end

  def coerce(val)
    [val, @number.coerce(val)[1]]
  end

  def number
    @number
  end

  def raise_coercion_exception(other_class)
    raise "Cannot coerce #{self.class} to #{other_class}"
  end

  def method_missing(name, *args, &blk)
    ret = @number.send(name, *args, &blk)
    # ret.is_a?(Float) ? Usd.new(ret) : ret
  end
end

def add_commas(number_str)
  number_str.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
end

class Usd < CustomNumber
  dominant_number_method :+, :-, :*, :**, :/
  def to_s
    i = @number.floor
    f = @number - i
    i_s = add_commas(i)
    "$" + i_s + sprintf("%.2f", f).sub(/^0/,'')
  end
end

class Rate < CustomNumber
  recessive_number_method :*, :/
  def initialize(number)
    number = number / 100.0
    super number
  end

  def to_s
    pct = @number * 100.0
    i = pct.floor
    f = pct - i
    i_s = add_commas(i)
    i_s + sprintf("%.2f%%", f).sub(/^0/,'')
  end
end
