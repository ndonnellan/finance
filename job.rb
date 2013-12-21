class Job < Account
  def initialize(salary, options={})
    super 0, options
    @salary = salary
  end

  def earn
    add_flow s = @salary / 12.0
    @taxable_income += s
  end

  def estimated_taxes
    compute_taxes(@salary)
  end
end