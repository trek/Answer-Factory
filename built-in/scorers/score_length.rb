# encoding: UTF-8
class ScoreLength < Scorer
  def score
    grab_answers, nudge_answers = answers.partition {|answer| answer.language == "grab" }
    
    scores = []
    
    nudge_answers.each do |answer|
      scores << make_score(:length, answer.blueprint.length, answer)
    end
    
    grab_answers.each do |answer|
      scores << make_score(:length, answer.blueprint.length, answer)
    end
    
    scores
  end
end
