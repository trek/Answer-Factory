# encoding: UTF-8
require File.dirname(__FILE__) + '/../../../spec_helper'

describe NudgeWriter do
  before(:each) do
    @writer = NudgeWriter.new
  end
  
  # it "langauge name is :Nudge" do
  #   @writer.language.should == :Nudge
  # end
  
  describe "block depth" do
    it "is ignored if block width is 1" do
      @writer.block_depth(15)
      @writer.block_width(1)
      @writer.use_instructions :int_add
      
      Random.should_receive(:rand).and_return(0,0,0.25)
      
      @writer.random.should == "do int_add\n"
    end
  end
  
  # describe "block depth" do
  #   before(:each) do
  #     @writer.block_width(2)
  #     @writer.use_instructions :int_add
  #   end
  #   
  #   it "defaults to 5" do      
  #     Random.should_receive(:rand).exactly(12).times.and_return(0, 0, 0, 0, 0, 0.25)
  #     @writer.random.should == "block { block { block { block { block { block { do int_add do int_add } do int_add } do int_add } do int_add } do int_add } do int_add }\n"
  #   end
  #   
  #   it "is set with block_depth" do
  #     Random.should_receive(:rand).exactly(14).times.and_return(0, 0, 0, 0, 0, 0, 0.25)
  #     
  #     @writer.block_depth(6)
  #     @writer.random.should == "block { block { block { block { block { block { block { do int_add do int_add } do int_add } do int_add } do int_add } do int_add } do int_add } do int_add }\n"
  #   end
  # end
  # 
  # describe "block width" do
  #   before(:each) do
  #     @writer.block_depth(1)
  #     @writer.use_instructions :int_add
  #   end
  #       
  #   it "defaults to 5" do
  #     Random.should_receive(:rand).exactly(5).times.and_return(0.25)
  #     @writer.random.should == "block { do int_add do int_add do int_add do int_add do int_add }\n"
  #   end
  #   
  #   it "is set with block_width" do
  #     @writer.block_width(6)
  #     Random.should_receive(:rand).exactly(6).times.and_return(0.25)
  #     @writer.random.should == "block { do int_add do int_add do int_add do int_add do int_add do int_add }\n"
  #   end
  # end
  # 
  # describe "code recursion depth" do
  #   it "defaults to 5" do
  #     pending
  #   end
  #   
  #   it "is set with block_depth" do
  #     pending
  #     @writer.code_recursion(10)
  #   end
  # end
  # 
  # describe "core language construct weights for block generation" do
  #   it "default to equal weight for each construct" do
  #     @writer.block_width(1)
  #     @writer.use_instructions :int_add
  #     @writer.use_refs :y
  #     @writer.stub!(:generate_value).and_return("value «float»")
  #     
  #     # first two calls occur from the first call to generate_block
  #     # 0: block call
  #     # 0.25 recursive generate_block from block call
  #     Random.should_receive(:rand).and_return(0, 0.25, 0.25, 0.5, 0.75)
  #     @writer.generate_block(1).should == "do int_add"
  #     @writer.generate_block(1).should == "do int_add"
  #     @writer.generate_block(1).should == "ref y"
  #     @writer.generate_block(1).should == "value «float»"
  #   end
  #   
  #   it "can be set with weight method" do
  #     @writer.weight({
  #       :block => 5,
  #       :do => 10,
  #       :ref => 5,
  #       :value => 5
  #     })
  #     @writer.block_width(1)
  #     @writer.use_instructions :int_add
  #     @writer.use_refs :y
  #     @writer.stub!(:generate_value).and_return("value «float»")
  #     
  #     # first two calls occur from the first call to generate_block
  #     # 0: block call
  #     # 0.2 recursive generate_block call from block call
  #     Random.should_receive(:rand).and_return(0, 0.2, 0.2, 0.6, 0.8)
  #     @writer.generate_block(1).should == "do int_add"
  #     @writer.generate_block(1).should == "do int_add"
  #     @writer.generate_block(1).should == "ref y"
  #     @writer.generate_block(1).should == "value «float»"
  #   end
  # end
  # 
  # describe "float range" do
  #   before(:each) do
  #     @writer = NudgeWriter.new
  #     @writer.block_width 1
  #     @writer.use_random_values :float
  #     
  #     # force value generation
  #     Random.should_receive(:rand).with(no_args).ordered.and_return(0.99)
  #   end
  #   
  #   it 'defaults to -100 to 100' do
  #     Random.should_receive(:rand).with(200).ordered.and_return(6)
  #     @writer.random.should == "value «float»\n«float»-94.0"
  #   end
  #   
  #   it 'can be set to a range' do
  #     @writer.float_range(10..400)
  #     Random.should_receive(:rand).with(390).ordered.and_return(50)
  #     @writer.random.should == "value «float»\n«float»60.0"
  #   end
  #   
  #   it 'can be set to a range in reverse order' do
  #     @writer.float_range(400..10)
  #     Random.should_receive(:rand).with(390).ordered.and_return(50)
  #     @writer.random.should == "value «float»\n«float»60.0"
  #   end
  # end
  # 
  # describe "int range" do
  #   before(:each) do
  #     @writer = NudgeWriter.new
  #     @writer.block_width 1
  #     @writer.use_random_values :int
  #     
  #     # force value generation
  #     Random.should_receive(:rand).with(no_args).ordered.and_return(0.99)
  #   end
  #   
  #   it 'defaults to -100 to 100' do
  #     Random.should_receive(:rand).with(200).ordered.and_return(49)
  #     @writer.random.should == "value «int»\n«int»-51"
  #   end
  #   
  #   it 'can be set to a range' do
  #     @writer.int_range(-10..212)
  #     Random.should_receive(:rand).with(222).ordered.and_return(66)
  #     @writer.random.should == "value «int»\n«int»56"
  #   end
  #   
  #   it 'can be set to a range in reverse order' do
  #     @writer.int_range(40..10)
  #     Random.should_receive(:rand).with(30).ordered.and_return(25)
  #     @writer.random.should == "value «int»\n«int»35"
  #   end
  # end
  # 
  # describe "available reference names" do
  #   before(:each) do
  #     @writer.block_width 1
  #     @writer.block_depth 1
  #     @writer.weight ref: 1
  #   end
  #   
  #   describe "defaults" do
  #     [:x1, :x2, :x3, :x4, :x5, :x6, :x7, :x8, :x9, :x10].each do |ref|
  #       it "contain #{ref}" do
  #         refs = @writer.instance_variable_get("@ref_names")
  #         refs.should_receive(:shuffle).and_return { [ref] }
  #         @writer.random.should == "ref #{ref}\n"
  #       end
  #     end
  #   end
  # 
  #   it "are set with use_refs" do
  #     @writer.use_refs :y5
  #     @writer.random.should == "ref y5\n"
  #   end
  #   
  #   it "guards against mistakingly adding language constructs as references" do
  #     [:block, :do, :ref, :value].each do |core_language_construct_name|
  #       @writer.use_refs :y5, :photo, core_language_construct_name
  #       @writer.instance_variable_get("@ref_names").should_not include(core_language_construct_name)
  #     end
  #   end
  # end
  # 
  # describe "available instructions" do
  #   before(:each) do
  #     @writer.block_depth 1
  #     @writer.block_width 1
  #     @writer.weight do: 1
  #   end
  #   
  #   it "defaults to all Nudge instructions" do
  #     @writer.instance_variable_get("@do_instructions").should == NudgeInstruction::INSTRUCTIONS.keys
  #   end
  #   
  #   it "are set with use_instructions" do
  #     @writer.use_instructions :foo_mix
  #     @writer.random.should == "do foo_mix\n"
  #   end
  #   
  #   it "guards against mistakingly adding language constructs as instructions" do
  #     [:block, :do, :ref, :value].each do |core_language_construct_name|
  #       @writer.use_instructions :foo_mix, :foo_splice, core_language_construct_name
  #       @writer.instance_variable_get("@do_instructions").should_not include(core_language_construct_name)
  #     end
  #   end
  # end
  # 
  # describe "generating a value" do
  #   it "generates a value of the provided type" do
  #     @writer.generate_value('float').should == 'value «float»'
  #   end
  #   
  #   it "stores a footnote stub for later addition" do
  #     @writer.generate_value('float')
  #     @writer.instance_variable_get("@footnotes_needed").should == ['float']
  #   end
  #   
  #   it "selects a random value type from available value type" do
  #     @writer.use_random_values :shirt
  #     @writer.generate_value.should == 'value «shirt»'
  #   end
  # end
end