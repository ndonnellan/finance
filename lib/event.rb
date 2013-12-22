class Event
  @@i = 0
  def initialize(name=nil, date=0, &block)
    @name = name || "event #{@@i+=1}"
    @date = date
    @block = block
  end

  def happen(*args)
    @block.call(*args)
  end

  def date; @date; end
end