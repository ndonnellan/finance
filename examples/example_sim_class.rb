require_relative '../init'
require_relative './scenarios/example_sim.rb'


sim = ExampleSim.new
sim.run til:Time.new(2030)
sim.print_log