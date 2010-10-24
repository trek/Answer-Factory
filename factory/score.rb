# encoding: UTF-8
class Score
  attr_reader :id, :name, :value, :scorer, :created, :answer_id
  
  # Internal use only.
  def initialize (name, value, answer_id, scorer, created)
    @name = name
    @value = value
    @answer_id = answer_id
    @scorer = scorer
    @created = created
  end
end
