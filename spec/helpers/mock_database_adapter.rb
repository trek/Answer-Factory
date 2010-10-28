module MockAdapter
  def log_comment(comment)
    @_mock_logged_comment = comment
  end
  
  def answer_count
    
  end
  
  def cycle
    @cycle || 0
  end
  
  def cycle!
    @cycle += 1 if @cycle
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
  extend MockAdapter
end