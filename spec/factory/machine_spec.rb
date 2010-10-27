require File.dirname(__FILE__) + '/../spec_helper'

describe Machine do
  describe "adding a route" do
    it "appends to existing routes" do
      machine = Machine.new
      machine.instance_variable_set("@routes",{})
    
      machine.send :best => :someplace
      machine.instance_variable_get("@routes").should == {:best => :someplace}
    
      machine.send :rest => :someplace_else
      machine.instance_variable_get("@routes").should == {:best => :someplace, :rest => :someplace_else}
    end    
  end
  
  it "returns answers keyed by language" do
    machine = Machine.new
    
    answer_0 = answer_factory(FakeBlueprint.new)
    answer_1 = answer_factory(FakeBlueprint.new)
    answer_2 = answer_factory(NudgeBlueprint.new("block {}"))
    
    machine.instance_variable_set("@answers", [answer_0, answer_1, answer_2])
    
    machine.answers_keyed_by_language.should == {
      :Fake => [answer_0, answer_1],
      :Nudge => [answer_2]
    }
  end
  
  describe "unknown labels" do
    
  end
end