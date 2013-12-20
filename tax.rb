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
  while true 
    t0 = TAX_SCHEDULE[bracket][1]
    t1 = TAX_SCHEDULE[bracket+1][1]
    if amount > t1
      tax += TAX_SCHEDULE[bracket+1][0]/100.0 * (t1 - t0)
    else
      tax += TAX_SCHEDULE[bracket+1][0]/100.0 * (amount - t0)
      break
    end

    bracket += 1
  end 

  tax
end

def compute_monthly_taxes(monthly_amounts)
  s = monthly_amounts.reduce(:+)
  total_tax = compute_taxes(s)
  return [total_tax/12.0]*12
end