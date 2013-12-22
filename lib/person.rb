COLUMNS = 15
class Person
  attr_reader :accounts, :tax_account

  def initialize(name)
    @name = name
  end

  def print_tax_rate
    total_income = @taxable_income.reduce(:+)
    total_tax = @taxes_paid.reduce(:+) + @tax_account.balance
    printf "eff tax|%#{spacing-1}.1f%%\n", (total_tax / total_income * 100.0)
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
    @accounts.each {|a| printf "%#{spacing-1}.1f%% |", a.year_change*100.0 }
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