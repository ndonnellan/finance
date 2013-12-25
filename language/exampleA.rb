company.job.create {
  income: $5000/mo
}

bank.create.account {
  type:checking,
  apy: 0.5,
  min_balance: $0,
  fees: [
    rule { balance < 0 ? $200 : 0 }
  ]
}

job -> irs (income.taxes)
job -> checking (income.after_taxes)
checking -> expenses (monthly)
[checking, savings, credit_card] -> expenses (monthly)
