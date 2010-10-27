require File.dirname(__FILE__) + '/../../spec_helper'

describe SplitLanguage do
  before(:each) do
    @machine = SplitLanguage.new
    answers = [
      @a1 = answer_factory(FakeBlueprint.new('')),
      @a2 = answer_factory(FakeBlueprint.new('')),
      @a3 = answer_factory(NudgeBlueprint.new('block {}'))
    ]
    
    @machine.instance_variable_set("@routes", {
      :best => 'nudgeroos',
      :rest => 'otherguys'
    })
    Factory.should_receive(:load_answers_at_machine).and_return(answers)
  end
  
  describe "splitting by language" do
    before(:each) do
      @machine.language :Nudge
    end
    
    it "sends answers with a specified langauge to the `best` path" do
      @machine.run      
      Factory.should have_answers(@a3).in_location('nudgeroos')
    end

    it "sends answers without the specified language to the `rest` path" do
      @machine.run
      Factory.should have_answers(@a1, @a2).in_location('otherguys')
    end
  end
end