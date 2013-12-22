
def savings_amount(acct)
  if acct.balance > acct.min_balance
    acct.balance - acct.min_balance
  else
    0.0
  end
end

class ExampleSim < Simulation
  def initialize
    super

    @checking = Account.new(3000 + rand, name:'checking', min_balance:3000)
    @savings = InterestAccount.new(5000, name:'savings', rate:0.5)
    @credit_card = CreditAccount.new(0.0, name:'cc', rate:11.0)

    @assets = [@checking, @savings]
    @debts = [@credit_card]

    @irs = TaxAccount.new(0, name:'taxman')
    @job = Job.new(30000.0, name:'google')
    @expenses = Expenses.bls_for_income(@job.salary*1.5)

    @tasks = {}

    @tasks[:withhold_taxes] = Proc.new {
      transfer from:@job, to:@irs, amount:@job.estimated_taxes/12.0
    }

    @tasks[:get_paycheck] = Proc.new {
      transfer_all from:@job, to:@checking
    }

    @tasks[:pay_off_expenses] = Proc.new {
      waterfall_transfer \
        priority:[@checking, @savings, @credit_card], 
        to:@expenses, amount:-@expenses.balance  
    }

    @tasks[:pay_off_cc] = Proc.new {
      waterfall_transfer \
        priority:[@checking, @savings], 
        to:@credit_card, amount:-@credit_card.balance
    }

    @tasks[:save_money] = Proc.new {
      transfer from:@checking, to:@savings, amount:savings_amount(@checking)
    }

    @tasks[:pay_taxes] = Proc.new {

    }

    self.each_month do
      
      income = @job.earn
      @tasks[:withhold_taxes].call
      @tasks[:get_paycheck].call  

      expense = @expenses.spend
      @tasks[:pay_off_expenses].call
      @tasks[:pay_off_cc].call
      @tasks[:save_money].call

    end

    self.each_year do
      total_taxable_income = collect :taxable_income, @job, @savings
      taxes = @irs.get_tax_bill total_taxable_income

      transfer from:@checking, to:@irs, amount:taxes
      if @checking.balance < @checking.min_balance
        transfer from:@savings, to:@checking, amount: (@checking.min_balance - @checking.balance)
      end

      @job.zero_taxable_income
      @savings.zero_taxable_income

      @irs.reset
    end

    self.add_event(Event.new('reduce_expenses', Time.new(2015)) do
      @expenses = Expenses.bls_for_income(@job.salary*0.9)
    end)

    self.add_event(Event.new('buy_a_house', Time.new(2020)) do
      @loan = MortgageAccount.new(-200000.0, 
        name:'mortgage', rate:4.5, term:30)
      @debts << @loan
      
      # Reduce expenses by housing costs (30%)
      @expenses.set_monthly_expense(@expenses.estimate_expenses * 0.70)
      self.each_month { @loan.accrue_interest }

      # Alter expense task to account for house
      @tasks[:pay_off_expenses] = Proc.new {
        waterfall_transfer \
          priority:[@checking, @savings, @credit_card], 
          to:@expenses, amount:-@expenses.balance  

        waterfall_transfer \
          priority:[@checking, @savings, @credit_card], 
          to:@loan, amount:[-@loan.balance, @loan.estimated_payment].min    

      }
    end)
  end
end