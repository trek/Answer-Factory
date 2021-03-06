# encoding: UTF-8
class SplitUnique < Machine
  def process_answers
    i = 0
    unique_answers = []
    
    while a = answers[i]
      blueprint = a.blueprint
      
      unmatched = unique_answers.each do |b|
        break false if b.blueprint == blueprint
      end
      
      if unmatched
        unique_answers << answers.delete_at(i)
      else
        i += 1
      end
    end
    
    label best: unique_answers
    label rest: answers
  end
end
