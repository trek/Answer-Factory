# encoding: UTF-8
class DoRandomDeletion < Machine
  def initialize
    @number_to_create = 1
    @points_to_delete = 1
  end
  
  def create (n)
    @number_to_create = n
  end
  
  def delete (n)
    @points_to_delete = n
  end
  
  def process_answers
    created = []
    
    answers.each do |answer|
      blueprint = answer.blueprint
      
      @number_to_create.times do
        new_blueprint = blueprint.delete_n_points_at_random(@points_to_delete)
        created << make_answer(new_blueprint, answer)
      end
    end
    
    label parents: answers
    label created: created
  end
end
