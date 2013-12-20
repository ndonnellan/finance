class Person
  attr_reader :accounts, :tax_account

  def initialize(name)
    @name = name
    @taxable_income = [0]*12
    @taxes_paid = [0]*12
    @accounts = []
  end

  def earns(amount, payer, type=:income)
    # Default to nothing. Should accrue to balances
    case type
    when :income
      @taxable_income[$month] += amount
    end

    amount
  end

  def owes(amount, payee)
    # Default to nothing. This means accounts with
    # balances will self-deduct. Could also mean that
    # accounts go negative
    amount
  end

  def pays_taxes(amount)
    @taxes_paid[$month] += amount
  end

  def addAccount(account)
    @accounts << account
    account.owner = self
  end

  def pay_taxes
    tax_per_month = compute_monthly_taxes @taxable_income

    @accounts.each do |account|
      if tax = account.get_withheld_taxes
        tax_per_month = tax_per_month.esub tax
      end
    end

    total_taxes = tax_per_month.reduce(:+)
    @tax_account ||= Account.new(0, 'taxman')
    @tax_account.balance -= total_taxes

    @accounts.each do |account|
      if account.class == CheckingAccount || account.class == SavingsAccount
        if account.balance <= @tax_account.balance
          t = Transaction.withdraw(:all)
        else
          t = Transaction.withdraw(@tax_account.balance)
        end

        t.from(account).depositInto(@tax_account).commit
      end

      break if @tax_account.balance >= 0
    end

    if @tax_account.balance < 0
      puts "Tax warning! $#{@tax_account.balance} in unpaid taxes"
    end

    self
  end

end

class Array
  def element_wise_add(a2)
    self.zip(a2).map {|e| e.reduce(:+) }
  end

  def element_wise_sub(a2)
    self.zip(a2).map {|e| e.reduce(:-) }
  end

  alias_method :element_wise_add, :eadd
  alias_method :element_wise_sub, :esub
end