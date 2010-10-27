require File.dirname(__FILE__) + '/../../spec_helper'

describe WrapBlock do
  before(:each) do
    @machine = WrapBlock.new
    answers = [
      @a1 = answer_factory(a:1, b:1),
      @a2 = answer_factory(a:2, b:3),
      @a3 = answer_factory(a:5, b:6)
    ]
    
    @machine.instance_variable_set("@routes", {
      :created => 'a',
      :parents => 'b'
    })
    Factory.should_receive(:load_answers_at_machine).and_return(answers)
  end
  
  describe "block wraps each answer" do
    it "once by default" do
      @machine.run
      
      Factory.should have_answers(@a1, @a2, @a3).in_location('b')
      Factory.should have_answers(@a1, @a2, @a3).evolved_by('wrap_block').once.in_location('a')
    end
    
    it "n times as set" do
      @machine.create 2
      @machine.run
      
      Factory.should have_answers(@a1, @a2, @a3).in_location('b')
      Factory.should have_answers(@a1, @a2, @a3).evolved_by('wrap_block').twice.in_location('a')
    end
    
  end
end