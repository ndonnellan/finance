class Class
  def create_number_method(*args)
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
  def create_logical_method(*args)
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
  create_number_method :+, :-, :*, :**, :/
  create_logical_method :>, :<, :>=, :<=, :==

  def initialize(num)
    unless num.class <= Numeric
      raise "Cannot cast #{num.class} to #{self.class}"
    end

    @number = num.to_f
  end

  def number
    @number
  end

  def raise_coercion_exception(other_class)
    raise "Cannot coerce #{self.class} to #{other_class}"
  end

  def method_missing(name, *args, &blk)
    ret = @number.send(name, *args, &blk)
    ret.is_a?(Float) ? Usd.new(ret) : ret
  end
end

class Usd < CustomNumber
  def to_s
    i = self.floor
    f = self - i
    i_s = i.to_s.reverse.gsub(/(\d{3})/, '\1,').reverse
    i_s + sprintf("%.2f", f)
  end
end

class Rate < CustomNumber
  def to_s
    pct = self * 100.0
    i = pct.floor
    f = pct - i
    i_s = i.to_s.reverse.gsub(/(\d{3})/, '\1,').reverse
    i_s + sprintf("%.1f", f)
  end
end
