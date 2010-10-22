# encoding: UTF-8
class UnwrapBlock < Machine
  def create (n)
    @number_to_create = n
  end
  
  def process_answers
    @number_to_create ||= 1
    
    created = []
    
    answers.each do |answer|
      blueprint = answer.blueprint
      
      @number_to_create.times do
        new_blueprint = blueprint.unwrap_block
        created << make_answer(new_blueprint, answer)
      end
    end
    
    label parents: answers
    label created: created
  end
end
