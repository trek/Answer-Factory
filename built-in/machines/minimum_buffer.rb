# encoding: UTF-8
class MinimumBuffer < Machine
  def initialize
    @minimum = 1
  end
  
  def minimum (n)
    @minimum = n
  end
  
  def process_answers
    label released: (answer_count >= @minimum) ? answers : []
  end
end
