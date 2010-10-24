# encoding: UTF-8
class DoPointCrossover < Machine
  def create (n)
    @pairs_to_create = (n.to_f / 2).ceil
  end
  
  def process_answers
    @pairs_to_create ||= 1
    
    created = []
    
    answers_keyed_by_language.each do |language, group|
      group.shuffle!.each_slice(2) do |a, b|
        b = a unless b
        
        blueprint_a = a.blueprint
        blueprint_b = b.blueprint
        
        @pairs_to_create.times do
          blueprint_c, blueprint_d = blueprint_a.point_crossover(blueprint_b)
          
          c = make_answer(blueprint_c, a, b)
          d = make_answer(blueprint_d, a, b)
          
          created.concat [c, d]
        end
      end
    end
    
    label parents: answers
    label created: created
  end
end
