# encoding: UTF-8
class ScoreAnswers < Machine
  def score_with (scorer_class)
    @scorer_class = scorer_class
  end
  
  def process_answers
    raise "no scorer specified for #{@location}" unless @scorer_class
    
    scores = @scorer_class.new.score(answers)
    Factory.save_scores(scores)
    
    label scored: answers
  end
end
