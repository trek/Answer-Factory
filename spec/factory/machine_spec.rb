require File.dirname(__FILE__) + '/../spec_helper'

describe Machine do
  describe "adding a route" do
    it "appends to existing routes" do
      machine = Machine.new("location")
    
      machine.send :best => :someplace
      machine.instance_variable_get("@routes").should == {:best => :someplace}
    
      machine.send :rest => :someplace_else
      machine.instance_variable_get("@routes").should == {:best => :someplace, :rest => :someplace_else}
    end    
  end
  
  describe "processing answers" do
    it "raises NoMethodError if process_answers is undefined and no process block is provided during configuration" do
      machine = Machine.new("location")
      lambda { machine.process_answers}.should raise_error(NoMethodError)
    end
    
    it "defaults to calling the process_answers" do
      machine = Machine.new("location")
      machine.should_receive(:process_answers)
      
      machine.instance_variable_get("@process").call
    end
  end
  
  it "returns answers keyed by language" do
    machine = Machine.new("location")
    
    answer_0 = Answer.new(FakeBlueprint.new)
    answer_1 = Answer.new(FakeBlueprint.new)
    answer_2 = Answer.new(NudgeBlueprint.new("block {}"))
    
    machine.instance_variable_set("@answers", [answer_0, answer_1, answer_2])
    
    machine.answers_keyed_by_language.should == {
      :Fake => [answer_0, answer_1],
      :Nudge => [answer_2]
    }
  end
end