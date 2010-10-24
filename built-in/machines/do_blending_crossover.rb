# encoding: UTF-8
class DoBlendingCrossover < Machine
  def initialize
    @number_to_create = 1
  end
  
  def create (n)
    @number_to_create = n
  end
  
  def process_answers
    created = []
    
    answers_keyed_by_language.each do |language, group|
      group.shuffle!.each_slice(2) do |a, b|
        b = a unless b
        
        blueprint_a = a.blueprint
        blueprint_b = b.blueprint
        
        @number_to_create.times do
          new_blueprint = blueprint_a.blending_crossover(blueprint_b)
          created << make_answer(new_blueprint, a, b)
        end
      end
    end
    
    label parents: answers
    label created: created
  end
end
