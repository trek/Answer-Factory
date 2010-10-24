# encoding: UTF-8
class Score
  def initialize (name, value, answer_id)
    @name = name.to_s
    @value = value.to_f
    @answer_id = answer_id.to_i
  end
  
  attr_reader :id, :name, :value, :scorer, :created, :answer_id
end
