require File.dirname(__FILE__) + '/../../spec_helper'

describe CloneGroupWinners do
  before(:each) do
    @machine = CloneGroupWinners.new
    answers = [
      @a1 = answer_factory('', a:1, b:1),
      @a2 = answer_factory('', a:2, b:3),
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
    @machine.instance_variable_set("@routes", {})
    Factory.should_receive(:save_answers).and_return(answers)
    Factory.should_receive(:load_answers_at_machine).and_return(answers)
  end
  
  describe "clones winners of tournaments" do
    it "it with supplied score names" do
      pending
    end
    
    describe "until a minimum number of new answers has been reached" do
      before(:each) do
        @machine.criteria(:a)
      end
      
      it "defaulting to 1 new answer" do
        pending
      end
      
      
      it "set to n" do
        pending
      end
    end
  end
  
  
  # describe "clones winners of tournaments" do
  #   before(:each) do
  #     @machine = CloneGroupWinners.new
  #   end
  #   describe "with supplied score names" do
  #     @machine.criteria(:a)
  #     @machine.process_answers
  #   end
  #   
  #   describe "until a minimum number of new answers has been reached" do
  #     before(:each) do
  #       @machine.criteria  :b
  #       @machine.group_size 2
  #     end
  #     
  #     it "defaulting to 1 new answer" do
  #       
  #     end
  #     
  #     it "set to n by the developer" do
  #       pending
  #     end
  #   end
  #   
  #   describe "in tournaments sized" do
  #     describe "7 as default" do
  #       
  #     end
  #     
  #     describe "as set" do
  #       
  #     end
  #   end
  #   
  #   it "labeling winners 'created'" do
  #   end
  #   
  #   it "labeling original answers 'parents'" do
  #   end
  # end
end