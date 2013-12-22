TAX_SCHEDULE = [
  [0.0,      0.0],
  [0.10,  8925.0],
  [0.15,  36250.0],
  [0.25,  87850.0],
  [0.28,  183250.0],
  [0.33,  398350.0],
  [0.35,  400000.0],
  [0.3960,  inf]]

def compute_taxes(amount)
  tax = amount*0.0
  bracket = 0
  while true 
    t0 = TAX_SCHEDULE[bracket][1]
    t1 = TAX_SCHEDULE[bracket+1][1]
    if amount > t1
      tax += TAX_SCHEDULE[bracket+1][0] * (t1 - t0)
    else
      tax += TAX_SCHEDULE[bracket+1][0] * (amount - t0)
      break
    end

    bracket += 1
  end 

  tax
end

def compute_monthly_taxes(monthly_amounts)
  s = monthly_amounts.reduce(:+)
  total_tax = compute_taxes(s)
  return [total_tax/12.0]*12.0
end