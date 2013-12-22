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