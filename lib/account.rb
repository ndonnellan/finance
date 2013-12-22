class Account
  attr_accessor :name
  @@i = 0
  def initialize(amount, options={})

    @name = options[:name] || "account #{@@i+=1}"
    @flows = [amount]
    @balance = amount
    @taxable_income = 0.0
    @min_balance = options[:min_balance] || 0.0
  end

  def reset
    @balance *= 0.0
    @flows = [@balance]
    @taxable_income *= 0.0
  end

  def add_flow(amount)
    @balance += amount
    @flows << amount
  end

  def balance
    @balance
  end

  def min_balance
    @min_balance
  end

  def balance_at(previous_period)
    if @flows.count < previous_period
      @balance*0
    else
      @flows[0..-previous_period].reduce(:+)
    end
  end

  def taxable_income; @taxable_income; end
  def zero_taxable_income; @taxable_income *= 0; end

  def account_log(msg)
    puts "#{self.name}|#{self.class}: #{msg}"
  end

  def annual_change
    prev_balance = balance_at(12)
    prev_balance == 0 ? 0*balance : balance / prev_balance
  end

end

class InterestAccount < Account
  def initialize(amount, options={})
    super amount, options
    @interest_rate = options[:rate]/100.0 || 0.0
    @interest_period = options[:period] || 1.0 # month
  end

  def accrue_interest(periods=1)
    i = @interest_rate * periods * @interest_period / 12 * balance
    transfer from:InifiniteAccount, to:self, amount:i
    @taxable_income += i
    i
  end
end

class CreditAccount < InterestAccount
  def initialize(amount, options={})
    super amount, options
    @min_balance = -inf
  end  
end

class MortgageAccount < CreditAccount
  def initialize(amount, options={})
    super amount, options
    @term = options[:term] || 1 # years
    i = @interest_rate / 12.0
    p = amount
    n = @term * 12 / @interest_period
    @payment = -(i * p * (1 + i)**n) /((1 + i)**n - 1)
  end

  def estimated_payment
    @payment
  end
end

class InifiniteAccount
  def self.balance
    raise "Cannot access balance of #{self}"
  end

  def self.add_flow(amount)
    nil
  end
end

class TaxAccount < Account
  def get_tax_bill(taxable_income)
    taxes_owed = compute_taxes(taxable_income)
    taxes_owed - self.balance
  end
end
