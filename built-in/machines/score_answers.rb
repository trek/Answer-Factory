# encoding: UTF-8
class ScoreAnswers < Machine
  def score_with (scorer_class)
    @scorer_class = scorer_class
  end
  
  def process_answers
    @scorer_class || raise(SomeErrorClass, "no scorer")
    
    scores = @scorer_class.new(answers).score
    Factory.save_scores(scores)
    
    label scored: answers
  end
end
