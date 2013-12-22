def transfer(options)
    options[:from].add_flow(-options[:amount])
    options[:to].add_flow(options[:amount])
    options[:amount]
end

def transfer_all(options)
  options[:amount] = options[:from].balance
  transfer options
end

def collect(sym, *args)
  args.collect { |a| a.send sym }.reduce(:+)
end

def waterfall_transfer(options)
  transferred = 0.0
  options[:priority].each do |account|
    if transferred < options[:amount]
      remaining = options[:amount] - transferred
      transferred += transfer \
        amount:[account.balance - account.min_balance, remaining].min,
        from:account,
        to:options[:to]
    end
  end
end