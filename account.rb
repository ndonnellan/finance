MONTHS_IN_YEAR = 12

class Account
  attr_accessor :name
  def initialize(amount, name="account")
    @balance = amount
    @name = name
    @interest_rate = 0.0
    @period = 1.0 # month
  end

  def balance
    @balance
  end

  def balance=(amount)
    @balance = amount
  end

  def owner=(person)
    @owner = person
  end

  def account_log(msg)
    puts "#{self.name}|#{self.class}: #{msg}"
  end

  def pay_interest(interest)
    amount_earned = @owner.earns interest_this_period, self, :income

    # If the owner doesn't take all of the amount paid
    # default to accruing interest
    if amount_earned > 0
      @balance += amount_earned
    end
    self
  end

  def interest_this_period
    @balance * @interest_rate/100.0 * @interest_period / MONTHS_IN_YEAR.to_f
  end


  def charge_fee(fee)
    # Ask the owner for payment on fee
    amount_owed = @owner.owes fee, self

    # If the owner doesn't pay enough to cover the fee,
    # subtract it from the account balance
    # (i.e. default to taking fees out of own balance)
    if amount_owed > 0
      @balance -= amount_owed
      account_log "Negative balance" if @balance < 0
    end
    self
  end

  def settle(periods=1)
    periods.times do |p|
      @account_actions.each { |a| self.send a }
    end
    self
  end

  def settle_year(years=1)
    self
  end

  def self.monthly_action(*args)
    @account_actions ||= []
    @account_actions += args
  end



end

class SavingsAccount < Account
  monthly_action :pay_interest
  def initialize(amount, name, rate=0.5)
    super amount, name
    @interest_rate = rate
  end
end

class CheckingAccount < Account
  monthly_action :pay_interest
  def initialize(amount, name, rate=0.05)
    super amount, name
    @interest_rate = rate
  end
end
