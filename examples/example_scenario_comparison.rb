require_relative '../init.rb'
require_relative './scenarios/example_sim.rb'
require 'pp'

sim1 = ExampleSim.new
sim2 = ExampleSim.new

logs = Simulation.compare \
  sims: [sim1, sim2],
  run_options: { til: Time.new(2020)}

pp logs
