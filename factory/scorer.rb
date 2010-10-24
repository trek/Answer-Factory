# encoding: UTF-8
class Scorer
  # Returns an array of the answers supplied to this scorer instance.
  # 
  #   def score
  #     scores = []
  #     
  #     answers.each do |a|
  #       ...
  #     end
  #     
  #     return scores
  #   end
  # 
  # Use this method inside a Scorer#score method definition.
  # 
  def answers
    @answers
  end
  
  # Makes an answer of the given name and value and associates it with answer.
  # 
  #   def score
  #     scores = []
  #     
  #     answers.each do |a|
  #       scores << make_scores(:length, answer.blueprint.length, answer)
  #     end
  #     
  #     return scores
  #   end
  # 
  def make_score (name, value, answer)
    Score.new(name.to_s, value.to_f, answer.id, self.class.to_s, Factory.cycle)
  end
  
  # Internal use only. Defined by Scorer subclasses.
  def score
    []
  end
  
  # Internal use only.
  def initialize (answers)
    @answers = answers
  end
end
