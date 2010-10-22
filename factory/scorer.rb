# encoding: UTF-8
class Scorer
  def initialize (answers)
    @answers = answers
  end
  
  def answers
    @answers
  end
  
  def score
    scores = []
    
    return scores
  end
  
  def make_score (name, value, answer)
    score = Score.new(name, value, answer.id)
    score.instance_variable_set(:@scorer, self.class.to_s)
    score.instance_variable_set(:@created, Factory.cycle)
    score
  end
end
