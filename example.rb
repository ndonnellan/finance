require_relative '_overrides'
require_relative 'tax'
require_relative 'account'
require_relative 'transaction'
require_relative 'job'
require_relative 'simulation'


checking = Account.new(3000, name:'checking')
savings = InterestAccount.new(5000, name:'savings', rate:0.5)
irs = TaxAccount.new(0, name:'taxman')
job = Job.new(30000.0, name:'google')

sim = Simulation.new

sim.each_month do

  job.earn
  transfer from:job, to:irs, amount:job.estimated_taxes/12.0
  transfer_all from:job, to:checking

  savings.accrue_interest
end

sim.each_year do

  total_taxable_income = collect :taxable_income, job, savings
  taxes = irs.get_tax_bill total_taxable_income
  transfer from:checking, to:irs, amount:taxes

  job.zero_taxable_income
  savings.zero_taxable_income

  printf "Earned: %6.0f\n", total_taxable_income
  printf "Tax rate: %.1f%%\n", irs.balance / total_taxable_income * 100.0
  irs.reset
end

sim.run

[job, checking, savings, irs].each do |acct|
  change = acct.annual_change.to_pct_str '%.1f%%'

  printf "Account: %10s | %6.0f (%s)\n", acct.name, acct.balance, change
end
