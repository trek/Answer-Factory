# encoding: UTF-8
class Answer
  def Answer.load (id, blueprint, location, created)
    answer = Answer.new(blueprint)
    answer.instance_variable_set(:@id, id)
    answer.instance_variable_set(:@location, location)
    answer.instance_variable_set(:@created, created)
    answer
  end
  
  def initialize (blueprint)
    @blueprint = blueprint
    @language = blueprint.language
  end
  
  attr_reader :id, :blueprint, :language, :location, :origin, :parent_ids, :created, :archived
  
  def assign (location)
    if location.to_s == "archive"
      @archived = Factory.cycle
    else
      @location = location
    end
    
    self
  end
  
  def score (score_name)
    raise "answer loaded without scores; cannot retrieve score" unless @scores
    (score = @scores[score_name.to_sym]) ? score.value : Factory::Infinity
  end
  
  def nondominated_vs? (other, criteria)
    nondominated_vs_other = true
    
    criteria.each do |score_name|
      self_score = self.score(score_name)
      other_score = other.score(score_name)
      
      if self_score < other_score
        nondominated_vs_other = true
        break
      elsif nondominated_vs_other
        nondominated_vs_other &&= (self_score == other_score)
      end
    end
    
    nondominated_vs_other
  end
end
