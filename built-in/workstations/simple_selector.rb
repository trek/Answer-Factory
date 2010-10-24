# encoding: UTF-8
class SimpleSelector < Workstation
  def minimum (n)
    @machines[:minimum].minimum n
  end
  
  def maximum (n)
    @machines[:score].maximum n
  end
  
  def criteria (*score_names)
    @machines[:split].criteria *score_names
  end
  
  def layers (n)
    @machines[:split].layers n
  end
  
  def score_with (scorer_class)
    @machines[:score].score_with scorer_class
  end
  
  def send (hash)
    @machines[:split].send best: hash[:best] if hash[:best]
    @machines[:split].send rest: hash[:rest] if hash[:rest]
  end
  
  def setup
    machine :split_unique, :SplitUnique
    machine :minimum, :MinimumBuffer
    machine :score, :ScoreAnswers
    machine :split, :SplitNondominated
    
    @machines[:split_unique].send best: "#{@name}:minimum"
    @machines[:split_unique].send rest: "archive"
    @machines[:minimum].send released: "#{@name}:score"
    @machines[:score].send scored: "#{@name}:split"
  end
end
