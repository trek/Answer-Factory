# encoding: UTF-8
class Answer
  attr_reader :id, :blueprint, :language, :location, :origin, :parent_ids, :created, :archived
  
  # Returns the value of the score named by score_name. Returns Infinity if
  # there is no such score.
  # 
  #   a.get_score(:score_1)   #=> 1.0449999
  #   a.get_score(:asdffjj)   #=> Infinity
  # 
  def get_score (score_name)
    raise "answer loaded without scores; cannot retrieve score" unless @scores
    (score = @scores[score_name.to_sym]) ? score.value : Factory::Infinity
  end
  
  # Returns true if this answer is nondominated versus other when compared
  # using the given criteria, false otherwise.
  # 
  #   a.nondominated_vs?(b, [:score_1, :score_2])   #=> true
  #   b.nondominated_vs?(a, [:score_1, :score_2])   #=> false
  # 
  def nondominated_vs? (other, criteria)
    nondominated_vs_other = true
    
    criteria.each do |score_name|
      self_score = self.get_score(score_name)
      other_score = other.get_score(score_name)
      
      if self_score < other_score
        nondominated_vs_other = true
        break
      elsif nondominated_vs_other
        nondominated_vs_other &&= (self_score == other_score)
      end
    end
    
    nondominated_vs_other
  end
  
  # Internal use only.
  def initialize (id, blueprint, location, origin, parent_ids, created, archived)
    @id = id
    @blueprint = blueprint
    @language = blueprint.language
    @location = location
    @origin = origin
    @parent_ids = parent_ids
    @created = created
    @archived = archived
  end
end
