module TestAdapter
  def log_comment(comment)
    @_mock_logged_comment = comment
  end
  
  def answer_count
    
  end
  
  def cycle
    1
  end
  
  def save_answers(answers)
    hash = Hash.new {|hash, key| hash[key] = []}
    answers.each do |answer|
      hash[answer.location.to_sym].push(answer)
    end
    
    @latest_saved_answers_by_location = hash
  end
end

class Factory
  extend TestAdapter
end