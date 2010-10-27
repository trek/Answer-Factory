require File.dirname(__FILE__) + '/../../spec_helper'

describe UnwrapBlock do
  before(:each) do
    @machine = UnwrapBlock.new
    answers = [
      @a1 = answer_factory('', a:1, b:1),
      @a2 = answer_factory('', a:2, b:3),
      @a3 = answer_factory('', a:5, b:6)
    ]
    
    @machine.instance_variable_set("@routes", {
      :created => 'mutated',
      :parents => 'original'
    })
    Factory.should_receive(:load_answers_at_machine).and_return(answers)
  end
  
  describe "block wraps each answer, sending original to `parents` and mutated to `created" do
    it "once by default" do
      @machine.run
      
      Factory.should have_answers(@a1, @a2, @a3).in_location('original')
      Factory.should have_answers(@a1, @a2, @a3).evolved_by('unwrap_block').once.in_location('mutated')
    end
    
    it "n times as set" do
      @machine.create 2
      @machine.run
      
      Factory.should have_answers(@a1, @a2, @a3).in_location('original')
      Factory.should have_answers(@a1, @a2, @a3).evolved_by('unwrap_block').twice.in_location('mutated')
    end
    
  end
end