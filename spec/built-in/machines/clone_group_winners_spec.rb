require File.dirname(__FILE__) + '/../../spec_helper'

describe CloneGroupWinners do
  before(:each) do
    @machine = CloneGroupWinners.new
    answers = [
      @a1 = answer_factory('', a:2, b:1),
      @a2 = answer_factory('', a:1, b:3),
      @a3 = answer_factory('', a:5, b:3),
      @a4 = answer_factory('', a:10, b:3),
      @a5 = answer_factory('', a:20, b:3),
      @a6 = answer_factory('', a:50, b:3),
      @a7 = answer_factory('', a:75, b:3),
      @a8 = answer_factory('', a:90, b:3),
      @a9 = answer_factory('', a:150, b:3),
      @a10 = answer_factory('', a:300, b:3),
      @a11 = answer_factory('', a:400, b:3),
      @a12 = answer_factory('', a:450, b:3),
      @a13 = answer_factory('', a:550, b:3),
      @a14 = answer_factory('', a:650, b:3),
      @a15 = answer_factory('', a:900, b:3),
    ]
    @machine.instance_variable_set("@routes", {
      :parents => 'originals',
      :created => 'winners'
    })
    Factory.should_receive(:load_answers_at_machine).and_return(answers)
  end
  
  describe "sends to `created` location, original to `created` location winners of tournaments" do
    it "of supplied score names" do
      @machine.criteria :a, :b
      mock_every_array_sample.and_return([0,1,2,3,4,5,6])
      @machine.run
      
      Factory.should have_answers(@a2).evolved.in_location('winners')
    end
    
    describe "until a minimum number of new answers has been reached" do
      before(:each) do
        @machine.criteria(:a)
      end
      
      it "defaulting to 1 new answer" do
        mock_every_array_sample.and_return([0,1,2,3,4,5,6])
        @machine.run
        
        Factory.should have_answers(@a2).evolved.in_location('winners')
      end
      

      it "set to n" do
        @machine.minimum 2
        mock_every_array_sample.and_return([0,1,2,3,4,5,6], [3,4,5,6,0])
        @machine.run
        
        Factory.should have_answers(@a2,@a1).evolved.in_location('winners')
      end
    end
  end
  
  describe "in tournaments sized" do
    it "7 as default" do
      expected_array = [0,1,2,3,4,5,6]
      mock_every_array_sample(7).and_return(expected_array)
      @machine.run
    end
    
    it "as set" do
      expected_array = [0,1,2]
      mock_every_array_sample(3).and_return(expected_array)
      @machine.group_size 3
      @machine.run
    end
  end
end