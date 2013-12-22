def inf
  100000000000.usd
end

def eps
  0.000000001
end

TAX_SCHEDULE = [
  [0.ir,      0.usd],
  [10.ir,  8925.usd],
  [15.ir,  36250.usd],
  [25.ir,  87850.usd],
  [28.ir,  183250.usd],
  [33.ir,  398350.usd],
  [35.ir,  400000.usd],
  [39.60.ir,  inf]]

def compute_taxes(amount)
  tax = amount*0
  bracket = 0
  while true 
    puts amount
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
  return [total_tax/12.0]*12
end