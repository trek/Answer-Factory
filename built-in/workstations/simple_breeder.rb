# encoding: UTF-8
class SimpleBreeder < Workstation
  def create (n)
    @machines[:crossover].create (n / 2.0).ceil
    @machines[:mutate].create (n / 2.0).floor
  end
  
  def mutate (n)
    @machines[:mutate].mutate n
  end
  
  def use_writer (writer_class)
    @machines[:mutate].use_writer writer_class
  end
  
  def send (hash)
    @machines[:crossover].send created: hash[:created] if hash[:created]
    @machines[:mutate].send created: hash[:created] if hash[:created]
    @machines[:mutate].send parents: hash[:parents] if hash[:parents]
  end
  
  def setup
    machine :crossover, :DoPointCrossover
    machine :mutate, :DoPointMutation
    
    @machines[:crossover].send parents: "#{@name}:mutate"
  end
end
