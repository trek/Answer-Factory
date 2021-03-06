# encoding: UTF-8
class GenerateRandomAnswers < Machine
  def initialize
    @number_to_create = 1
    @writer = Writer.new
  end
  
  def create (n)
    @number_to_create = n
  end
  
  def use_writer (writer_class)
    @writer = writer_class.new
  end
  
  def process_answers
    created = []
    
    @number_to_create.times do
      created << make_answer(@writer.random)
    end
    
    label created: created
  end
end
