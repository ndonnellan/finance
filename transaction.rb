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