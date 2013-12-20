require_relative 'tax'
require_relative 'account'
require_relative 'transaction'
require_relative 'investments'
require_relative 'person'
require_relative 'job'



years = 1
me = Person.new('sally')

checking = CheckingAccount.new(3000, 'checking')
savings = SavingsAccount.new(5000, 'savings')
job = Job.new(30000.0)

me.addAccount savings
me.addAccount checking
me.addAccount job

me.print_account_names

years.times do |year|
  12.times do |month|
    $month = month

    me.accounts.each { |a| a.settle }
    Transaction.withdraw(:all).from(job).depositInto(checking).commit
    me.print_account_balances
  end

  me.accounts.each { |a| a.settle_year }

  me.group_taxes
  me.print_tax_rate
  me.pay_taxes

  puts "end-of-year balances"
  me.print_account_balances
  me.print_account_changes
  puts "-"*10

end
