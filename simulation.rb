class Simulation
  def initialize
    @monthly_actions = []
    @yearly_actions = []
  end

  def each_month(&block)
    @monthly_actions << block
  end

  def each_year(&block)
    @yearly_actions << block
  end

  def run(months=12)
    months.times do |month|
      puts month
      @monthly_actions.each { |ma| ma.call month }

      if (month+1) % 12 == 0
        @yearly_actions.each { |ya| ya.call }
      end
    end
  end
end