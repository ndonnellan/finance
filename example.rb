Dir.glob("./*.rb") { |file| require file }

checking = Account.new(3000, name:'checking', min_balance:3000)
savings = InterestAccount.new(5000, name:'savings', rate:0.5)
irs = TaxAccount.new(0, name:'taxman')
job = Job.new(30000.0, name:'google')
expenses = Expenses.bls_for_income(job.salary*2.5)
sim = Simulation.new

def savings_amount(acct)
  if acct.balance > acct.min_balance
    acct.balance - acct.min_balance
  else
    0.0
  end
end

sim.each_month do
  
  income = job.earn
  sim.log income:income.usd

  transfer from:job, to:irs, amount:job.estimated_taxes/12.0
  transfer_all from:job, to:checking

  expense = expenses.spend
  sim.log expense:expense.usd
  sim.log net:(income - expense).usd

  # transfer from:checking, to:expenses, amount:-expenses.balance
  waterfall_transfer \
    priority:[checking, savings, credit_card], 
    to:expenses, amount:-expenses.balance


  transfer from:checking, to:savings, amount:savings_amount(checking)
  sim.log \
    interest:savings.accrue_interest.usd,
    checking:checking.balance.usd,
    savings:savings.balance.usd,
    cc_interest:credit_card.accrue_interest.usd,
    cc_balance:credit_card.balance.usd


end

sim.each_year do
  total_taxable_income = collect :taxable_income, job, savings
  taxes = irs.get_tax_bill total_taxable_income

  transfer from:checking, to:irs, amount:taxes
  if checking.balance < checking.min_balance
    transfer from:savings, to:checking, amount: (checking.min_balance - checking.balance)
  end

  job.zero_taxable_income
  savings.zero_taxable_income

  sim.log \
    taxable_income: total_taxable_income.usd, 
    taxes:irs.balance.usd,
    tax_rate:(irs.balance / total_taxable_income).pct,
    checking:checking.balance.usd,
    savings:savings.balance.usd

  irs.reset
end

sim.run

sim.print_log('monthly')