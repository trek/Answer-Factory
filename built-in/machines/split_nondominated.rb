# encoding: UTF-8
class SplitNondominated < Machine
  def initialize
    @load_scores = true
    @criteria = []
    @layers = 1
  end
  
  def criteria (*score_names)
    @criteria = score_names
  end
  
  def layers (n)
    @layers = n
  end
  
  def maximum (n)
    @maximum = n
  end
  
  def process_answers
    best = []
    rest = answers.shuffle
    
    @layers.times do
      indices_of_best = []
      
      rest.each_with_index do |a, index|
        nondominated = true
        
        answers.each do |b|
          break unless nondominated &&= a.nondominated_vs?(b, @criteria)
        end
        
        indices_of_best << index if nondominated
      end
      
      indices_of_best.reverse.each do |i|
        best << rest.delete_at(i)
      end
    end
    
    if @maximum && best.shuffle!.length > @maximum
      rest.concat best.slice!(@maximum..-1)
    end
    
    label best: best
    label rest: rest
  end
end
