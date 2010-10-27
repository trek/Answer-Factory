require File.dirname(__FILE__) + '/../../spec_helper'

describe SplitUnique do
  before(:each) do
    @machine = SplitUnique.new
    answers = [
      @a1 = answer_factory(FakeBlueprint.new('abc'), a:1, b:1),
      @a2 = answer_factory(FakeBlueprint.new('abc'), a:2, b:3),
      @a3 = answer_factory(FakeBlueprint.new('def'), a:5, b:6)
    ]
    
    @machine.instance_variable_set("@routes", {
      :best => 'unique',
      :rest => 'copies'
    })
    Factory.should_receive(:load_answers_at_machine).and_return(answers)
  end
  
  it "sends answers with unique blueprints to the `best` path" do
    @machine.run
    Factory.should have_answers(@a3).in_location('unique')
  end
  
  it "sends answers that are not unqiue to the `rest` path" do
    @machine.run
    Factory.should have_answers(@a1, @a2).in_location('copies')
  end
end