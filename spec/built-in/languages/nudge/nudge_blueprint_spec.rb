# encoding: UTF-8
require File.dirname(__FILE__) + '/../../../spec_helper'

describe NudgeBlueprint do
  it "langauge name is :Nudge" do
    blueprint = NudgeBlueprint.new
    blueprint.language.should == :Nudge
  end
  
  describe "deleting points at random" do
    before(:each) do
      code = "block { ref x value «code» do int_add }\n«int»1\n«code»value «int»\n«int»2"
      @blueprint = NudgeBlueprint.new(code)
    end
    
    it "returns a new blueprint" do
      @blueprint.delete_n_points_at_random(1).should be_kind_of(NudgeBlueprint)
    end
    
    it "does not alter the orginal blueprint" do
      new_blueprint = @blueprint.delete_n_points_at_random(1)
      @blueprint.should_not == new_blueprint
    end
    
    it "removes a random point from the program once when called with 1" do
      Random.should_receive(:rand).with(3).and_return(2)
      @blueprint.delete_n_points_at_random(1).should == "block { ref x value «code» }\n«code»value «int»\n«int»1" 
    end
    
    it "removes a random point from the program n-times when when called with n" do
      Random.should_receive(:rand).with(3).ordered.and_return(2)
      Random.should_receive(:rand).with(2).ordered.and_return(1)
      
      @blueprint.delete_n_points_at_random(2).should == "block { ref x }\n" 
    end
    
    it "raises NudgeError::PointIndexTooLarge if called with n higher than number of points" do      
      lambda { @blueprint.delete_n_points_at_random(12)}.should raise_error(NudgeError::PointIndexTooLarge)
    end
  end
  
  describe "inserting points at random" do
    before(:each) do
      code = "block { ref x value «code» do int_add }\n«int»1\n«code»value «int»\n«int»2"
      @blueprint = NudgeBlueprint.new(code)
      @writer = NudgeWriter.new
      @writer.stub!(:random).and_return(NudgeBlueprint.new("do foo_bar"))
    end
    
    it "returns a new blueprint" do
      @blueprint.insert_n_points_at_random(1, @writer).should be_kind_of(NudgeBlueprint)
    end
    
    it "does not alter the orginal blueprint" do
      new_blueprint = @blueprint.insert_n_points_at_random(1, @writer)
      @blueprint.should_not == new_blueprint
    end
    
    it "inserts a random point into the program once when called with 1" do
      Random.should_receive(:rand).with(3).and_return(1)
      @blueprint.insert_n_points_at_random(1, @writer).should == "block { ref x value «code» do foo_bar do int_add }\n«code»value «int»\n«int»1" 
    end
    
    it "inserts a random point into the program n-times when called with n" do
      Random.should_receive(:rand).with(3).ordered.and_return(2)
      Random.should_receive(:rand).with(4).ordered.and_return(2)
      
      @blueprint.insert_n_points_at_random(2, @writer).should == "block { ref x value «code» do int_add do foo_bar do foo_bar }\n«code»value «int»\n«int»1" 
    end
  end

  describe "mutating points at random" do
    before(:each) do
      code = "block { ref x value «code» do int_add }\n«int»1\n«code»value «int»\n«int»2"
      @blueprint = NudgeBlueprint.new(code)
      @writer = NudgeWriter.new
      @writer.stub!(:random).and_return(NudgeBlueprint.new("do foo_bar"))
    end
    
    it "returns a new blueprint" do
      @blueprint.mutate_n_points_at_random(1, @writer).should be_kind_of(NudgeBlueprint)
    end
    
    it "does not alter the orginal blueprint" do
      new_blueprint = @blueprint.mutate_n_points_at_random(1, @writer)
      new_blueprint.should_not == @blueprint
    end
    
    it "mutates a point at random when called with 1" do
      Random.should_receive(:rand).once.with(4).and_return(1)
      @blueprint.mutate_n_points_at_random(1, @writer).should == "block { do foo_bar value «code» do int_add }\n«code»value «int»\n«int»1"
    end
    
    it "mutates n points at random when called with n" do      
      Random.should_receive(:rand).with(4).twice.and_return(2)
      @blueprint.mutate_n_points_at_random(2, @writer).should == "block { ref x do foo_bar do int_add }\n" 
    end
  end

  describe "mutate values at random" do
    before(:each) do
      code = "block { ref x value «code» do int_add }\n«int»1\n«code»value «int»\n«int»2"
      @blueprint = NudgeBlueprint.new(code)
      @writer = NudgeWriter.new
      @writer.use_random_values :int
      @writer.stub!(:random).and_return(NudgeBlueprint.new("do foo_bar"))
    end
    
    it "returns a new blueprint" do
      @blueprint.mutate_n_values_at_random(1, @writer).should be_kind_of(NudgeBlueprint)
    end
    
    it "does not alter the orginal blueprint" do
      new_blueprint = @blueprint.mutate_n_values_at_random(1, @writer)
      new_blueprint.should_not == @blueprint
    end
    
    it "mutates a value at random when called with 1" do
      pending
      @blueprint.mutate_n_values_at_random(1, @writer).should == ''
    end
    
    it "mutates n values at random when called with n" do      
      pending
    end
  end

  describe "blending crossover" do
    before(:each) do
      @blueprint_a = NudgeBlueprint.new("block { ref x value «code» do int_add }\n«int»1\n«code»value «int»\n«int»2")
      @blueprint_b = NudgeBlueprint.new("block { ref y ref z value «int» do int_add }\n«int»1")
    end
    
    it "combines some points at random from two blueprints into a new blueprint" do
      new_blueprint = @blueprint_a.blending_crossover(@blueprint_b)
      new_blueprint.should_not == @blueprint_a
      new_blueprint.should_not == @blueprint_b
    end
    
    it "produces a blueprint of with a random number of points whose maximum is the total number of points of the two donor blueprints" do
      Random.should_receive(:rand).with(7).and_return(3)
      new_blueprint = @blueprint_a.blending_crossover(@blueprint_b)
      NudgePoint.from(new_blueprint).points.should == 5
    end
    
    it "does not introduce points into the new blueprint that were not in either of the donor blueprints" do
      Random.should_receive(:rand).with(7).and_return(3)
      points_a = NudgePoint.from(@blueprint_a).instance_variable_get("@points")
      points_b = NudgePoint.from(@blueprint_b).instance_variable_get("@points")
      points_n = NudgePoint.from(@blueprint_a.blending_crossover(@blueprint_b)).instance_variable_get("@points")
      
      points_n.each do |point|
        (points_a + points_b).collect {|p| p.to_script }.should include(point.to_script)
      end
      
    end
  end
end