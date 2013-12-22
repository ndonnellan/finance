class Simulation
  def initialize
    @monthly_actions = []
    @yearly_actions = []
    @store = {}
    @log_month = true
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

  def run(options={})
    @t = options[:from] || Time.now
    tF = options[:til] || Time.new(@t.year+1,@t.month)

    @log_level = ''
    while @t < tF
      @log_level = 'month'
      advance_month

      @monthly_actions.each { |ma| ma.call @t.month}

      if @t.month % 12 == 0
        @log_level = 'year'
        @yearly_actions.each { |ya| ya.call @t.year}
      end
      
    end
    @log_level = ''
  end

  def log(args)
    yr = @t.year
    mon = @t.month
    @store[yr] ||= {}

    accumulate = Proc.new {|k,ov,nv| ov + nv}

    case @log_level
    when 'year'
      @store[yr].merge! args, &accumulate
    when 'month'
      @store[yr][mon] ||= {}
      @store[yr][mon].merge! args, &accumulate
    else
      @store.merge! args, &accumulate
    end
  end

  def get_log
    @store
  end

  def print_log(type='annual')
    Log.format(@store, type)
  end


end


