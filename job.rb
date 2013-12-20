class Job < Account
  monthly_action :pay_salary
  def initialize(salary, name='job')
    super 0, name
    @name = name
    @salary = salary
    @withheld_taxes = [0]*12
    @withholding_rate = compute_taxes(salary) / salary
  end

  def pay_salary
    taxes = @salary * @withholding_rate / 12.0
    @balance += @owner.earns @salary/12.0, self, :income
    @withheld_taxes[$month] += taxes
    self
  end

  def get_withheld_taxes
    taxes = @withheld_taxes.dup
    @withheld_taxes = [0]*12
    taxes
  end

end