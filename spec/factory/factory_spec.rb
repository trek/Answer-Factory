require File.dirname(__FILE__) + '/../spec_helper'
class FakeWorkstation < Workstation; end
describe Factory do
  before(:each) do
    Factory.reset
  end
  
  describe "adding a workstation" do
    before(:each) do
      @workstation = Factory.workstation('sample', :FakeWorkstation)
    end
    
    it "adds it to the list of workstations by name" do
      Factory.instance_variable_get("@workstations").should include(:sample)
    end
    
    it "sets the machine class as the provided class name" do
      @workstation.class.should == FakeWorkstation
    end
    
    it "schedules the workstation by name in the order it was defined" do
      Factory.workstation('test', :FakeWorkstation)
      Factory.instance_variable_get("@schedule").should == [:sample, :test]
    end
  end
  
  describe "scheduling workstations" do
    before(:each) do
      Factory.workstation('sample', :Workstation)
      Factory.workstation('test', :Workstation)
    end
    
    it "occrus by name in the order it was defined" do
      Factory.instance_variable_get("@schedule").should == [:sample, :test]
    end
    
    it "can be declared in a specific order" do
      Factory.schedule(:test, :sample)
      Factory.instance_variable_get("@schedule").should == [:test, :sample]
    end
  end
  
  describe "starting" do
    before(:each) do
      workstation = Factory.workstation('test', :Workstation)
      @machine1 = workstation.machine('sample1', :MockMachine)
      @machine2 = workstation.machine('sample2', :MockMachine)
    end
    
    it "logs a supplied comment" do
      Factory.stop_at(10)
      Factory.should_receive(:answer_count).and_return(0,5,10)
      
      comment = 'Improved what it does: awesome'
      Factory.should_receive(:log_comment).with(comment)
      
      Factory.start(comment)
    end
    
    it "calls run on each machine in the scheduled order" do
      Factory.stop_at(2)
      Factory.should_receive(:answer_count).and_return(0,2)
      
      @machine1.should_receive(:run).once.ordered
      @machine2.should_receive(:run).once.ordered
      
      Factory.start
    end
    
    it "runs until a minimum desired number of answers is reached" do
      Factory.stop_at(20)
      Factory.should_receive(:answer_count).and_return(1,5,19,20)
      
      Factory.start
    end
    
  end
end