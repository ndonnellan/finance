class Transaction
  attr_accessor :inflows, :outflows
  def self.withdraw(amount)
    t = Transaction.new
    t.withdraw amount
    t
  end

  def withdraw(amount)
    @outflows ||= []
    @outflows << { from:nil, amount:amount }
    self
  end

  def from(account)
    @outflows[-1][:from] = account
    self
  end

  def depositInto(account, x=1)
    @inflows ||= []
    if @inflows.empty?
      x ||= 1
    else
      x ||= 1 - @inflows.reduce(0) {|s, o| s + o.fraction }
    end

    @inflows << { to:account, fraction:x}
    self
  end

  def reverse(actions)
    actions.each do |action|
      action[:account].balance += -action[:change]
    end
  end

  def commit
    pending = []
    temporary_sum = 0
    total_x = @inflows.reduce(0) { |s, i| s + i[:fraction] }
    if total_x != 1
      raise InvalidTransactionError, "Inflows requested greater than 100%"
    end

    until @outflows.empty?
      source = @outflows.pop
      if source[:amount] == :all
        source[:amount] = source[:from].balance
      elsif source[:from].balance < source[:amount]
        reverse pending
        raise InsufficientFundsError.new(nil, source)
      end

      temporary_sum += source[:amount]
      source[:from].balance -= source[:amount]
      pending << { account:source[:from], change:-source[:amount]}

    end

    until @inflows.empty?
      sink = @inflows.pop

      sink[:to].balance += temporary_sum * sink[:fraction]
    end

    self
  end
end

class InsufficientFundsError < StandardError
  def initialize(message=nil, outflow=nil)
    @message = message || begin
      if outflow
        "Not enough funds in #{outflow[:from].name}(#{outflow[:from].balance})
         to withdraw #{outflow[:amount]}"
       else
        "Not enough funds to withdraw"
      end
    end
  end
end

class InvalidTransactionError < StandardError
end