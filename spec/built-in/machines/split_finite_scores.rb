require File.dirname(__FILE__) + '/../../spec_helper'

describe SplitFiniteScores do
  before(:each) do
    @machine = SplitFiniteScores.new
    answers = [
      @a1 = answer_factory('', a:1, b:1),
      @a2 = answer_factory('', a:2, b:3),
      @a3 = answer_factory('', a:Factory::Infinity, b:6)
    ]
    
    @machine.instance_variable_set("@routes", {
      :best => 'infinite',
      :rest => 'finite'
    })
    Factory.should_receive(:load_answers_at_machine).and_return(answers)
  end
  
  describe "splitting by criteria" do
    before(:each) do
      @machine.criteria :a
    end
    
    it "sends answers with a inifinite score to the `best` path" do
      @machine.run      
      Factory.should have_answers(@a3).in_location('infinite')
    end

    it "sends answers with an inifinite score `rest` path" do
      @machine.run
      Factory.should have_answers(@a1, @a2).in_location('finite')
    end
  end
end