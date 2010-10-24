# encoding: UTF-8
class DoRandomInsertion < Machine
  def initialize
    @number_to_create = 1
    @points_to_insert = 1
    @writer = Writer.new
  end
  
  def create (n)
    @number_to_create = n
  end
  
  def insert (n)
    @points_to_insert = n
  end
  
  def use_writer (writer_class)
    @writer = writer_class.new
  end
  
  def process_answers
    created = []
    
    answers.each do |answer|
      blueprint = answer.blueprint
      
      @number_to_create.times do
        new_blueprint = blueprint.insert_n_points_at_random(@points_to_insert, @writer)
        created << make_answer(new_blueprint, answer)
      end
    end
    
    label parents: answers
    label created: created
  end
end
