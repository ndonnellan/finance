class ExampleRichSim < ExampleSim
  def initialize(*args)
    super(*args)
    @savings.rate = 1.5

  end
end