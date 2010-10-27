require File.join(File.dirname(__FILE__), '..', 'answer_factory')
require File.join(File.dirname(__FILE__), 'matchers', 'have_answers')

require 'spec'

module Guid
  @id = 0
  def self.id
    @id += 1
    @id
  end
end


module TestAdapter
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

def answer_factory(attributes = nil)
  # (id, blueprint, location, origin, parent_ids, created, archived)
  answer = Answer.new(Guid.id, FakeBlueprint.new, nil, nil, nil, nil, nil)
  answer.instance_variable_set("@scores", score_factory(attributes))
  return answer
end

def score_factory(scores)
  # (name, value, answer_id, scorer, created)
  hash = {}
  return hash unless scores
  scores.each do |name,value|
    hash[name] = Score.new(name, value, nil, nil, nil)
  end
  return hash
end

class FakeBlueprint < NudgeBlueprint
  attr_reader :changes
  @uid = 0
  
  def self.uid
    @uid += 1
    @uid
  end
  
  def initialize(parent = nil)
    @changes = []
    t = Time.now
    b = Guid.id
    super(parent || "#{b} at #{t.to_i.to_s}:#{t.usec.to_s}")
  end
  
  def changed(how)
    @changes.push(how)
    self
  end
  
  def language
    :Fake
  end
  
  def blending_crossover (other)
    FakeBlueprint.new(other.blueprint)
  end
  
  def delete_n_points_at_random (n)
    FakeBlueprint.new("-- fake -- ")
  end
  
  def mutate_n_points_at_random (n)
    FakeBlueprint.new("-- fake -- ")
  end
  
  def mutate_n_values_at_random (n)
    FakeBlueprint.new("-- fake -- ")
  end
  
  def point_crossover (other)
    FakeBlueprint.new("-- fake -- ")
  end
  
  def unwrap_block
    FakeBlueprint.new(self).changed('unwrap_block')
  end
  
  def wrap_block
    FakeBlueprint.new(self).changed('wrap_block')
  end
end

class Answer
  def ==(other)
    @blueprint == other.blueprint
  end
end

class Factory
  def self.cycle
    1
  end
  
  def self.reset
    @workstations = nil
    @schedule = nil
  end
end