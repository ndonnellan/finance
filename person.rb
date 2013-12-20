COLUMNS = 15
class Person
  attr_reader :accounts, :tax_account

  def initialize(name)
    @name = name
    @taxable_income = [0]*12
    @taxes_paid = [0]*12
    @accounts = [Account.new(0, 'taxman')]
    @tax_account = @accounts[0]
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

  def group_taxes
    tax_per_month = compute_monthly_taxes @taxable_income

    @accounts.each do |account|
      if tax = account.get_withheld_taxes
        tax_per_month = tax_per_month.esub tax
        @taxes_paid = @taxes_paid.eadd tax
      end
    end

    total_taxes = tax_per_month.reduce(:+)
    @tax_account.balance -= total_taxes
  end

  def print_tax_rate
    total_income = @taxable_income.reduce(:+)
    total_tax = @taxes_paid.reduce(:+) + @tax_account.balance
    printf "eff tax|%#{spacing-1}.1f%%\n", (total_tax / total_income * 100.0)
  end

  def pay_taxes
    @accounts.each do |account|
      if account.class == CheckingAccount || account.class == SavingsAccount
        if account.balance <= -@tax_account.balance
          t = Transaction.withdraw(:all)
        else
          t = Transaction.withdraw(-@tax_account.balance)
        end

        t.from(account).depositInto(@tax_account).commit
      end

      break if @tax_account.balance >= 0
    end

    if @tax_account.balance > -eps
      @tax_account.balance = 0
    end

    @taxable_income = [0]*12
    @taxes_paid = [0]*12

    if @tax_account.balance < 0
      puts "Tax warning! $#{@tax_account.balance.round} in unpaid taxes"
    else

    end

    self
  end

  def max_account_name_length
    @accounts.collect {|a| a.name.length }.max
  end

  def spacing
    @spacing ||= [ max_account_name_length, COLUMNS].max
  end

  def print_account_names
    print " month |"
    @accounts.each {|a| printf "%#{spacing}s |", a.name }
    print "\n"
  end

  def print_account_balances
    printf "%6s |", $month+1
    @accounts.each {|a| printf "%#{spacing}.0f |", a.balance }
    print "\n"    
  end

  def print_account_changes
    print "change |"
    @accounts.each {|a| printf "%#{spacing}.1f%%|", a.year_change*100.0 }
    print "\n"
  end


end

class Array
  def element_wise_add(a2)
    self.zip(a2).map {|e| e.reduce(:+) }
  end

  def element_wise_sub(a2)
    self.zip(a2).map {|e| e.reduce(:-) }
  end

  alias_method :eadd, :element_wise_add
  alias_method :esub, :element_wise_sub
end