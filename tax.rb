def inf
  100000000000
end

def eps
  0.000000001
end

TAX_SCHEDULE = [
  [0,      0],
  [10.00,  8925],
  [15.00,  36250],
  [25.00,  87850],
  [28.00,  183250],
  [33.00,  398350],
  [35.00,  400000],
  [39.60,  inf]]

def compute_taxes(amount)
  tax = 0
  bracket = 0
  remaining = amount
  loop do 
    t0 = TAX_SCHEDULE[bracket][1]
    t1 = TAX_SCHEDULE[bracket+1][1]

    d = [ remaining, t1 - t0 ].min
    tax += TAX_SCHEDULE[bracket+1][0]/100.0 * d
    remaining -= d
    bracket += 1
    
    break if (remaining > 0 && bracket < TAX_SCHEDULE.count)
  end 

end

def compute_monthly_taxes(monthly_amounts)
  s = monthly_amounts.reduce(:+)
  total_tax = compute_taxes(s)
  return [total_tax/12.0]*12
end