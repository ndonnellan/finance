class Simulation
  attr_reader :name
  @@i = 0
  def initialize(name=nil)
    @name = name || "sim #{@@i+=1}"
    @monthly_actions = []
    @yearly_actions = []
    @store = {}
    @log_month = true
    @events = []
    @assets = []
    @debts = []
  end

  def assets
    @assets.reduce(0) {|s, a| s + a.balance }
  end

  def debts
    @debts.reduce(0) {|s, d| s + d.balance }
  end

  def net_worth
    assets - debts
  end

  def advance_month
    if @t.mon == 12
      @t = Time.new(@t.year + 1, 1)
    else
      @t = Time.new(@t.year, @t.mon + 1)
    end
  end

  def each_month(&block)
    @monthly_actions << block
  end

  def each_year(&block)
    @yearly_actions << block
  end

  def add_event(event)
    @events << event
  end

  def run(options={})
    @t = options[:from] || Time.now
    tF = options[:til] || Time.new(@t.year+1,@t.month)

    # Sort events by date so that they can be
    # set in arbitrary order beforehand
    @events.sort_by! {|e| e.date }

    @log_level = ''
    while @t < tF
      @log_level = 'month'
      advance_month

      while @events.count > 0 && @events[0].date < @t
        @events.shift.happen
      end

      @monthly_actions.each { |ma| ma.call @t.month}

      if @t.month % 12 == 0
        @log_level = 'year'
        @yearly_actions.each { |ya| ya.call @t.year}
      end
      
    end
    @log_level = ''
  end

  def log(args, custom_store=nil)
    store = custom_store || @store

    yr = @t.year
    mon = @t.month
    store[yr] ||= {}

    accumulate = Proc.new {|k,ov,nv| ov + nv}

    case @log_level
    when 'year'
      store[yr].merge! args, &accumulate
    when 'month'
      store[yr][mon] ||= {}
      store[yr][mon].merge! args, &accumulate
    else
      store.merge! args, &accumulate
    end
  end

  def get_log
    @store
  end

  def print_log(type='annual')
    Log.format(@store, type)
  end


  class << self
    def compare(options)
      sims = options[:sims]

      logs = [{}] * sims.count

      sims.each_with_index do |sim, i|
        sim.each_year do
          sim.log(
            {assets:sim.assets,
            debts:sim.debts,
            net_worth:sim.net_worth}
            )
        end

        sim.run options[:run_options]
        logs[i] = sim.get_log
      end

      logs
    end
  end
end


