class Job < Account
  monthly_action :pay_salary
  def initialize(salary)
    @salary = salary
    @withheld_taxes = [0]*12
    @withholding_rate = compute_taxes salary
  end

  def pay_salary
    taxes = @salary * @withholding_rate / MONTHS_IN_YEAR.to_f
    @balance += @owner.earns @salary, self, :income
    @withheld_taxes[$month] += taxes
    self
  end

  def get_withheld_taxes
    taxes = @withheld_taxes.dup
    @withheld_taxes = [0]*12
    taxes
  end

end