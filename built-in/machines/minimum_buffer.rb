# encoding: UTF-8
class MinimumBuffer < Machine
  def minimum (n)
    @minimum = n
  end
  
  def process_answers
    @minimum ||= 1
    
    label released: (answer_count >= @minimum) ? answers : []
  end
end
