class Expenses < Account
  class << self
    def bls_for_income(income)
      # Use BLS data to estimate expenses per month, minus
      # the category of personal savings/insurance 
      # (which is 10% in the US)
      expenses = self.new(income*0)
      expenses.set_monthly_expense(income * 49705.0 / 63685.0 * 0.90 / 12)
      expenses
    end
  end
  def set_monthly_expense(amount)
    @total_monthly_expense = amount
  end

  def spend
    add_flow(-@total_monthly_expense)
    @total_monthly_expense
  end
end