# encoding: UTF-8
class SplitFiniteScores < Machine
  def initialize
    @load_scores = true
  end
  
  def criteria (*score_names)
    @criteria = score_names
  end
  
  def process_answers
    best, rest = answers.partition do |answer|
      any_infinite_score = false
      
      @criteria.each do |score_name|
        infinite = (answer.get_score(score_name) == Factory::Infinity)
        break if any_infinite_score ||= infinite
      end
      
      any_infinite_score
    end
    
    label best: best
    label rest: rest
  end
end
