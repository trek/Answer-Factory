# encoding: UTF-8
class MutateValues < Machine
  def initialize
    @number_to_create = 1
    @values_to_mutate = 1
    @writer = Writer.new
  end
  
  def create (n)
    @number_to_create = n
  end
  
  def mutate (n)
    @values_to_mutate = n
  end
  
  def use_writer (writer_class)
    @writer = writer_class.new
  end
  
  def process_answers
    created = []
    
    answers.each do |answer|
      blueprint = answer.blueprint
      
      @number_to_create.times do
        new_blueprint = blueprint.mutate_n_values_at_random(@values_to_mutate, @writer)
        created << make_answer(new_blueprint, answer)
      end
    end
    
    label parents: answers
    label created: created
  end
end
