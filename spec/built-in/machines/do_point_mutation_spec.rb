require File.dirname(__FILE__) + '/../../spec_helper'

describe DoPointMutation do
  before(:each) do
    @machine = DoPointMutation.new
    answers = [
      @a1 = answer_factory('', a:1, b:1),
      @a2 = answer_factory('', a:2, b:3),
      @a3 = answer_factory('', a:5, b:6)
    ]
    
    @machine.instance_variable_set("@routes", {
      :created => 'mutated',
      :parents => 'original'
    })
    Factory.stub!(:load_answers_at_machine).and_return(answers)
  end
  
  describe "mutates answers via 'point_mutation'" do
    it "sending original to `parents`" do
      @machine.run
      Factory.should have_answers(@a1, @a2, @a3).in_location('original')
    end
    
    it "sending mutated to `created`" do
      @machine.run
      Factory.should have_answers(@a1, @a2, @a3).evolved_by('point_mutation').in_location('mutated')
    end
    
    it "once by default" do
      @machine.run
      
      Factory.should have_answers(@a1, @a2, @a3).evolved_by('point_mutation').once.in_location('mutated')
    end
    
    it "n times as set" do
      @machine.create 2
      @machine.run
      
      Factory.should have_answers(@a1, @a2, @a3).in_location('original')
      Factory.should have_answers(@a1, @a2, @a3).evolved_by('point_mutation').twice.in_location('mutated')
    end
    
  end
end