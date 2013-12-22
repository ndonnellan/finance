require_relative '_overrides'
require_relative 'tax'
require_relative 'account'
require_relative 'transaction'
require_relative 'job'
require_relative 'simulation'
require_relative 'log'
require_relative 'expenses'


checking = Account.new(3000, name:'checking', min_balance:3000)
savings = InterestAccount.new(5000, name:'savings', rate:0.5)
irs = TaxAccount.new(0, name:'taxman')
job = Job.new(30000.0, name:'google')
expenses = Expenses.bls_for_income(job.salary)
sim = Simulation.new

def savings_amount(acct)
  if acct.balance > acct.min_balance
    acct.balance - acct.min_balance
  else
    0
  end
end

sim.each_month do

  sim.log income:job.earn
  transfer from:job, to:irs, amount:job.estimated_taxes/12.0
  transfer_all from:job, to:checking
  expenses.spend

  transfer from:checking, to:expenses, amount:-expenses.balance


  transfer from:checking, to:savings, amount:savings_amount(checking)
  sim.log interest:savings.accrue_interest

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
    taxable_income: total_taxable_income, 
    taxes:irs.balance,
    rate:irs.balance / total_taxable_income * 100,
    checking:checking.balance,
    savings:savings.balance

  irs.reset
end

sim.run til:Time.new(2050)

sim.print_log('annual')