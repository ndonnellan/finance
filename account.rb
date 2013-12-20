class Class
  def monthly_action(*args)
    class_eval %Q{
      @account_actions ||= []
      @account_actions += args
    }
  end
end
class Account
  attr_accessor :name, :year_change

  def initialize(amount, name="account")

    @balance = amount
    @name = name
    @interest_rate = 0.0
    @interest_period = 1.0 # month
    @starting_balance = amount
  end

  def self.account_actions
    @account_actions
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

  def pay_interest
    amount_earned = @owner.earns interest_this_period, self, :income

    # If the owner doesn't take all of the amount paid
    # default to accruing interest
    if amount_earned > 0
      @balance += amount_earned
    end
    self
  end

  def interest_this_period
    @balance * @interest_rate/100.0 * @interest_period / 12.0
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
      if self.class.account_actions
        self.class.account_actions.each { |a| self.send a }
      end
    end
    self
  end

  def settle_year(years=1)
    @year_change = if @starting_balance == 0
      0
    else
      (@balance - @starting_balance) / @starting_balance
    end

    @starting_balance = @balance
    self
  end

  def get_withheld_taxes
    nil
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
