# encoding: UTF-8
class Machine
  # Defines the process applied to answers by this machine.
  # 
  #   Factory.setup do
  #     workstation :w do
  #       machine :m do
  #         process do
  #           ...
  #         end
  #         
  #         ...
  #       end
  #     end
  #   end
  # 
  # Use this method inside a #machine block.
  # 
  def process (&block)
    @process = block
  end
  
  # Specifies the location to send answers to designated by the given labels.
  # These labels must match the labels given to Machine#label.
  # 
  #   Factory.setup do
  #     workstation :w do
  #       machine :m do
  #         ...
  #         
  #         send group1: "w:m1"
  #         send group2: "w:m2"
  #       end
  #     end
  #   end
  # 
  # Use this method inside a #machine block.
  # 
  def send (hash)
    @routes.merge! hash
  end
  
  # Specifies the answers to be referred to by the given labels. These labels
  # must match the labels given to Machine#send.
  # 
  #   def process_answers
  #     ary1 = []
  #     ary2 = []
  #     
  #     answers.each do |a|
  #       ...
  #     end
  #     
  #     label group1: ary1
  #     label group2: ary2
  #   end
  # 
  # Use this method inside a #process block or inside a
  # Machine#process_answers method definition.
  # 
  def label (hash)
    @labeled_answers.merge! hash
  end
  
  # Returns an array of the answers currently at this machine. By default,
  # scores are not loaded. Set @load_scores=true in this machine to override.
  # 
  #   def process_answers
  #     @load_scores = true
  #     
  #     answers.each do |a|
  #       ...
  #     end
  #     
  #     label group1: ary1
  #     label group2: ary2
  #   end
  # 
  # Use this method inside a #process block or inside a
  # Machine#process_answers method definition.
  # 
  def answers
    @answers ||= Factory.load_answers_at_machine(@location, @load_scores)
  end
  
  # Returns a hash of the answers currently at this machine, keyed by language
  # name as a symbol. By default, scores are not loaded. Set @load_scores=true
  # in this machine to override.
  # 
  #   def process_answers
  #     @load_scores = true
  #     
  #     answers_keyed_by_language.each do |language, array|
  #       ...
  #     end
  #     
  #     label group1: ary1
  #     label group2: ary2
  #   end
  # 
  # Use this method inside a #process block or inside a
  # Machine#process_answers method definition.
  # 
  def answers_keyed_by_language
    hash = Hash.new {|h,k| h[k] = [] }
    
    answers.each do |answer|
      hash[answer.language] << answer
    end
    
    hash
  end
  
  # Returns a new answer with the given blueprint and parents.
  # 
  #   def process_answers
  #     answers.each do |a|
  #       ary1 << make_answer(a.blueprint, a)
  #       ary2 << make_answer(a.blueprint.reverse, a)
  #     end
  #     
  #     label group1: ary1
  #     label group2: ary2
  #   end
  # 
  # Use this method inside a #process block or inside a
  # Machine#process_answers method definition.
  # 
  def make_answer (blueprint, *parents)
    parent_ids = parents.collect {|answer| answer.id }
    Answer.new(nil, blueprint, @location, @location, parent_ids, Factory.cycle, nil)
  end
  
  # Returns the number of answers currently at this machine without forcing
  # the answers to load.
  # 
  #   def process_answers
  #     if answer_count > 500
  #       ...
  #     end
  #     
  #     label group1: ary1
  #   end
  # 
  # Use this method inside a #process block or inside a
  # Machine#process_answers method definition.
  # 
  def answer_count
    return @answers.length if @answers
    
    Factory.count_answers_at_machine(@location)
  end
  
  # Internal use only. Defined by Machine subclasses.
  def process_answers
    raise NoMethodError, "define process for machine #{@location} before running factory"
  end
  
  # Internal use only.
  def run
    @answers = nil
    @labeled_answers = {}
    
    @process ? @process.call : process_answers
    
    answers_to_save = []
    
    @labeled_answers.each do |label, output_answers|
      new_location = @routes[label]
      
      answers_to_save.concat(if new_location == "archive"
        output_answers.collect {|a| a.instance_variable_set(:@archived, Factory.cycle); a }
      else
        output_answers.collect {|a| a.instance_variable_set(:@location, new_location); a }
      end)
    end
    
    Factory.save_answers(answers_to_save)
  end
end
