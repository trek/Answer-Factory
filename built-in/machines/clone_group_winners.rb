# encoding: UTF-8
class CloneGroupWinners < Machine
  def initialize
    @load_scores = true
    @criteria = []
    @group_size = 7
    @minimum = 1
  end
  
  def criteria (*score_names)
    @criteria = score_names
  end
  
  def group_size (n)
    @group_size = n
  end
  
  def minimum (n)
    @minimum = n
  end
  
  def process_answers
    created = []
    
    while created.length < @minimum
      group = answers.sample(@group_size)
      
      group.each do |a|
        nondominated = true
        
        group.each do |b|
          break unless nondominated &&= a.nondominated_vs?(b, @criteria)
        end
        
        created << make_answer(a.blueprint, a) if nondominated
      end
    end unless answers.empty? || @group_size == 0
    
    label parents: answers
    label created: created
  end
end
