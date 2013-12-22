def add_commas(number_str)
  number_str.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
end

class Numeric
  def usd
    i = self.floor
    f = self - i
    i_s = add_commas(i)
    "$" + i_s + sprintf("%.2f", f).sub(/^0/,'')
  end

  def pct
    pct = self * 100.0
    i = pct.floor
    f = pct - i
    i_s = add_commas(i)
    i_s + sprintf("%.2f%%", f).sub(/^0/,'')
  end
end