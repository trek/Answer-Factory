#encoding: utf-8
require File.join(File.dirname(__FILE__), "../spec_helper")

describe "Answer" do
  
  describe "initialization" do
    it "should accept a string OR a NudgeProgram as an initialization parameter" do
      lambda{Answer.new("any string")}.should_not raise_error
      lambda{Answer.new(NudgeProgram.new("block {}"))}.should_not raise_error
    end
    
    it "should validate the initial parameter and make sure it's only one of the accepted classes" do
      lambda{Answer.new(8812.9)}.should raise_error(ArgumentError)
      lambda{Answer.new(Time.now)}.should raise_error(ArgumentError)
      lambda{Answer.new}.should raise_error(ArgumentError)
    end
    
    it "should set the #draft_blueprint attribute from the string, if present" do
      Answer.new("do x").draft_blueprint.should == "do x"
      Answer.new("some «random»\njunk").draft_blueprint.should == "some «random»\njunk"
    end
    
    it "should set the #draft_blueprint attribute to the blueprint of the NudgeProgram, if present" do
      Answer.new(NudgeProgram.new("value «foo»\n«foo» bar")).draft_blueprint.should ==
        "value «foo» \n«foo» bar"
    end
    
    it "should set the #program attribute to a new NudgeProgram based on init'n string, if present" do
      np = Answer.new("do x").program
      np.should be_a_kind_of(NudgeProgram)
      np.blueprint.should == "do x"
    end
    
    it "should set the #program attribute even if the init'n string is unparseable" do
      np = Answer.new("not a program")
      np.program.should be_a_kind_of(NudgeProgram)
      np.draft_blueprint.should == "not a program"
      np.program.linked_code.should be_a_kind_of(NilPoint)
      np.program.blueprint.should == ""
    end
    
    it "should set the #program attribute to the init'n NudgeProgram, if present" do
      prog = NudgeProgram.new("block {ref a ref b}")
      na = Answer.new(prog)
      na.program.should == prog
      na.draft_blueprint.should == prog.blueprint
    end
    
    it "should respond to #blueprint by returning self.program.blueprint" do
      prog = NudgeProgram.new("block {ref a do x}")
      na = Answer.new(prog)
      prog.should_receive(:blueprint).and_return("hi there")
      na.blueprint.should == "hi there"
    end
    
    it "should have a #scores hash, which is empty" do
      Answer.new("foo").scores.should == {}
    end
    
    it "should have a tags attribute" do
      Answer.new("").should respond_to(:tags)
    end
    
    it "should be possible to set the :tags via initialization option" do
      Answer.new("", tags:["hi"]).tags.to_a.should == ["hi"]
    end
    
    it "should not report duplicate entries" do
      Answer.new("", tags:["hi", "hi"]).tags.to_a.should == ["hi"]
    end
    
    it "should have a :location attribute" do
      Answer.new("").should respond_to(:location)
    end
    
    it "should have a default :location of :NOWHERE" do
      Answer.new("").location.should == :NOWHERE
    end
    
    it "be possible to set :location via an initialization option" do
      Answer.new("", location:"nearby").location.should == "nearby"
    end
    
    it "should have a #timestamp, which is when (wall clock time) it was made" do
      tn = Time.now
      Time.should_receive(:now).and_return(tn)
      Answer.new("bar").timestamp.should == tn
    end
        
    it "should have a [named] #progress attribute, defaulting to zero" do
      Answer.new("baz").progress.should == 0
      Answer.new("baz", progress:12).progress.should == 12
    end
    
    it "should have an #ancestors Array, defaulting to []" do
      Answer.new("quux").ancestors.should == []
      Answer.new("quux", ancestors:[1,2,3]).ancestors.should == [1,2,3]
    end
  end
  
  
  describe "serialization" do
    describe "writing" do
      before(:each) do
        @a1 = Answer.new("block {do a}", progress:12, location: :here)
      end
      
      it "should not contain the CouchDB _id, if none was set" do
        @a1.data['_id'].should == nil
      end
      
      it "should contain the couch_id, if one is set" do
        a2 = Answer.new("",couch_id:'1234')
        a2.data['_id'].should == '1234'
      end
      
      it "should not contain the CouchDB _rev, if none was set" do
        @a1.data['_rev'].should == nil
      end
      
      it "should contain the CouchDB _rev, if the Answer has a non-nil :couch_rev" do
        @a1.couch_rev = "88888"
        @a1.data['_rev'].should == "88888"
      end
      
      it "should contain the blueprint" do
        @a1.data['blueprint'].should == @a1.blueprint
      end
      
      it "should contain the location" do
        @a1.data['location'].should == @a1.location
      end
      
      it "should contain the tags" do
        @a1.data['tags'].should == @a1.tags.to_a
      end
      
      
      it "should contain the scores" do
        @a1.data['scores'].should == @a1.scores
      end
      
      it "should contain the progress" do
        @a1.data['progress'].should == @a1.progress
      end
      
      
      it "should contain the timestamp" do
        @a1.data['timestamp'].should == @a1.timestamp
      end
    end
    
    describe "reading" do
      before(:each) do
        @couchified = {"id"=>"0f60c293ad736abfdb083d33f71ef9ab", "key"=>"ws1", "value"=>{"_id"=>"0f60c293ad736abfdb083d33f71ef9ab", "_rev"=>"1-473467b6dc1a4cba3498dd6eeb8e3206", "blueprint"=>"do bar", "location"=>"here","tags"=>["quux", "whatevz"], "scores"=>{"badness" => 12.345}, "progress" => 12, "timestamp"=>"2010/04/14 17:09:14 +0000"}}
        @my_a = Answer.from_serial_hash(@couchified)
      end
      
      it "should record the couchdb_id" do
        @my_a.couch_id.should == "0f60c293ad736abfdb083d33f71ef9ab"
      end
      
      it "should record the couchdb_rev" do
        @my_a.couch_rev.should == "1-473467b6dc1a4cba3498dd6eeb8e3206"
      end
      
      
      it "should accept a blueprint string" do
        @my_a.blueprint.should == "do bar"
      end
      
      it "should accumulate the :location" do
        @my_a.location.should == :here
      end
      
      it "should collect the tag Array into a Set of symbols" do
        @my_a.tags.should be_a_kind_of(Set)
        @my_a.tags.should include(:quux)
        @my_a.tags.should include(:whatevz)
      end
            
      it "should gather up the scores Hash" do
        @my_a.scores.should be_a_kind_of(Hash)
        @my_a.scores.should include(:badness)
      end
      
      it "should read the progress" do
        @my_a.progress.should == 12
      end
      
    end
  end
  
  
  describe "#parses?" do
    it "should respond to #parses? with an answer from its NudgeProgram" do
      Answer.new("not good word").parses?.should == false
      Answer.new("block {do nice_nudge}").parses?.should == true
    end
  end
  
  
  describe "scores" do
    before(:each) do
      @answer1 = Answer.new("do a")
      @answer1.scores[:error] = 81.9
      @answer1.scores[:a_1] = 2200
      
      @answer2 = Answer.new("some other crap")
      @answer2.scores[:error] = 7
      @answer2.scores[:a_1] = 1200
    end
    
    it "should require symbols as keys" do
      lambda{@answer2.scores["foo"]}.should raise_error(ArgumentError)
      lambda{@answer2.scores[:bar]}.should_not raise_error(ArgumentError)
    end
    
    describe "#known_criteria" do
      it "#known_criteria should return a sorted list of the keys of the scores hash" do
        @answer1.known_criteria.should == [:a_1, :error]
        Answer.new("x").known_criteria.should == []
      end
    end
    
    describe "#score_vector" do
      it "#score_vector should return an Array of #scores" do
        a1s = @answer1.score_vector
        a1s.should be_a_kind_of(Array)
        a1s.sort.should == [2200, 81.9].sort # ignoring returned orderuntil next spec
      end
      
      it "should use the argument to order the scores in the result" do
        @answer1.score_vector([:a_1]).should == [2200]
        @answer1.score_vector([:error, :a_1]).should == [81.9, 2200]
      end
      
      it "the scores should be by default in #known_criteria (alphabetical) order" do
        @answer1.scores[:bobby] = -121.1
        a1s = @answer1.score_vector
        a1s[0].should == @answer1.scores[:a_1]
        a1s[1].should == @answer1.scores[:bobby]
        a1s[2].should == @answer1.scores[:error]
      end
      
      it "should return nil for any nonexistent score item" do
        @answer1.score_vector([:nonexisto, :a_1]).should == [nil, 2200]
      end
    end
    
    describe "#dominated_by?" do
      
      it "should return false when the compared Answer doesn't have the same scoring_criteria" do
        @answer1.scores = {a:10}
        @answer2.scores = {     b:99}
        @answer1.dominated_by?(@answer2).should == false
        
        @answer1.scores = {a:10, b:10}
        @answer2.scores = {      b:99, c:10}
        @answer1.dominated_by?(@answer2).should == false
        
        @answer1.scores = {a:10, b:10, c:10, d:10}
        @answer2.scores = {      b:99, c:10, d:1}
        @answer1.dominated_by?(@answer2).should == false
        
        @answer1.scores = {x1:1, x2:2, x3:3}
        @answer2.scores = {      x2:0,      x4:12}
        @answer1.dominated_by?(@answer2).should == false
        @answer2.dominated_by?(@answer1).should == false
      end
      
      it "should use the comparison template to check whether the scoring criteria are the same" do
        @answer1.scores = {a:10, b:10, c:10, d:10}
        @answer2.scores = {      b:99, c:10, d:1}
        @answer1.dominated_by?(@answer2).should == false
        
        @answer1.scores = {a:10, b:10, c:10, d:10}
        @answer2.scores = {      b:99, c:10, d:1}
        @answer1.dominated_by?(@answer2, [:d]).should == true
        @answer2.dominated_by?(@answer1, [:b,:c]).should == true
      end
      
      it "should return true if another Answer has one score better and all the rest the same" do
        @answer1.scores = {:a => 10, :b =>10}
        @answer2.scores = {:a => 10, :b => 9}
        @answer1.dominated_by?(@answer2).should == true
      end
      
      it "should return false if another Answer has all scores worse" do
        @answer1.scores = {:a => 10, :b =>10}
        @answer2.scores = {:a=> 1000, :b => 1000}
        @answer1.dominated_by?(@answer2).should == false
      end
      
      it "should return false if another Answer has all scores the same and one worse" do
        @answer1.scores = {:a => 10, :b =>10}
        @answer2.scores = {:a=> 10, :b => 1000}
        @answer1.dominated_by?(@answer2).should == false
      end
      
      it "should return false if another Answer has some scores better and some worse" do
        @answer1.scores = {:a => 10, :b =>10}
        @answer2.scores = {:a=> 1000, :b => 1}
        @answer1.dominated_by?(@answer2).should == false
      end
      
      it "should return true if another Answer has all scores better" do
        @answer1.scores = {:a => 10, :b =>10}
        @answer2.scores = {:a=> 1, :b => 1}
        @answer1.dominated_by?(@answer2).should == true
      end
      
      it "should return false if another Answer has all scores identical" do
        @answer1.scores = {:a => 10, :b =>10}
        @answer2.scores = {:a=> 10, :b => 10}
        @answer1.dominated_by?(@answer2).should == false
      end
      
      it "should use known_criteria if no comparison template is passed in" do
        @answer1.scores = {:a => 10, :b =>10, :c => 100}
        @answer2.scores = {:a=> 1, :b => 1, :c => 99}
        @answer1.should_receive(:known_criteria).at_least(1).times.and_return([:a,:b,:c])
        @answer1.dominated_by?(@answer2).should == true
      end
      
      it "should use a comparison template if one is passed in" do
        @answer1.scores = {:a => 10, :b =>10, :c => 10}
        @answer2.scores = {:a=> 1, :b => 200, :c => 10}
        @answer1.dominated_by?(@answer2, [:a]).should == true
        @answer1.dominated_by?(@answer2, [:b]).should == false
        @answer1.dominated_by?(@answer2, [:c]).should == false
        
        @answer2.dominated_by?(@answer1, [:a]).should == false
        @answer2.dominated_by?(@answer1, [:b]).should == true
        @answer2.dominated_by?(@answer1, [:c]).should == false
        
        @answer1.dominated_by?(@answer2, [:a, :c]).should == true
        @answer2.dominated_by?(@answer1, [:b, :c]).should == true
      end
      
      
      it "should be conservative when comparing against a missing score" do
        @answer1.scores = {:a => 10, :b =>nil, :c => 100}
        @answer2.scores = {:a=> 1, :b => 12, :c => 99}
        lambda{@answer1.dominated_by?(@answer2)}.should_not raise_error(NoMethodError)
        @answer1.dominated_by?(@answer2).should == false
      end
    end
  end
  
  
  describe "#points method" do
    it "should return self.program.points" do
      Answer.new("").points.should == 0
      Answer.new("block {do a do b}").points.should == 3
      Answer.new("block {value «foo» block {value «foo»}}").points.should == 4
    end
  end
  
  
  describe "replace_point_or_clone" do
    before(:each) do
      @simple = Answer.new("block { do a do b do c do d do e}")
      @complicated = Answer.new("block { block {do a} do b block { block {do c} block {do d}} do e}")
      @str_insert  = "ref x"
      @pt_insert = ReferencePoint.new("y")
    end
    
    it "should return a NudgeProgram (not an Answer)" do
      @simple.replace_point_or_clone(2,@str_insert).should be_a_kind_of(NudgeProgram)
    end
    
    it "should return a clone of the original NudgeProgram if the position param is out of bounds" do
      new_guy = @simple.replace_point_or_clone(-11,"do x")
      new_guy.blueprint.should == @simple.blueprint
      new_guy.object_id.should_not == @simple.program.object_id
      
      new_guy = @simple.replace_point_or_clone(1911,"do x")
      new_guy.blueprint.should == @simple.blueprint
    end
    
    it "should raise an ArgumentError if passed an unparseable replacement" do
      lambda{@simple.replace_point_or_clone(3,"some crap")}.should raise_error(ArgumentError)
      lambda{@simple.replace_point_or_clone(3,"block {}")}.should_not raise_error
    end
    
    it "should produce a new parsable NudgeProgram with a new blueprint (as expected)" do
      @simple.replace_point_or_clone(2,@str_insert).blueprint.should ==
        "block {\n  ref x\n  do b\n  do c\n  do d\n  do e}"
      @complicated.replace_point_or_clone(2,@str_insert).blueprint.should ==
        "block {\n  ref x\n  do b\n  block {\n    block {\n      do c}\n    block {\n      do d}}\n  do e}"
    end
    
    it "should replace the expected specific point (and any subpoints and footnotes it has)" do
      a1 = Answer.new("block {value «code» value «int»}\n«code» value «float»\n«float» 1.1\n«int» 12")
      a1.replace_point_or_clone(2,"do x").blueprint.should ==
        "block {\n  do x\n  value «int»} \n«int» 12"
    end
        
    it "should insert the new footnotes it needs in the right place in the footnote_section" do
      a1 = Answer.new("block {value «code» value «int»}\n«code» value «float»\n«float» 1.1\n«int» 12")
      a1.replace_point_or_clone(3,"value «foo»\n«foo» bar").blueprint.should ==
        "block {\n  value «code»\n  value «foo»} \n«code» value «float»\n«float» 1.1\n«foo» bar"
    end
    
    it "should not affect extra (unused) footnotes" do
      a1 = Answer.new("block {value «int»}\n«float» 1.1\n«int» 12")
      a1.replace_point_or_clone(2, "do x").blueprint.should ==
        "block {\n  do x} \n«float» 1.1"
    end
    
    it "should work when putting in something that lacks a footnote" do
      @simple.replace_point_or_clone(3, "value «quux»").blueprint.should ==
        "block {\n  do a\n  value «quux»\n  do c\n  do d\n  do e} \n«quux»"
    end
    
    it "should act as expected when replacing the root" do
      @simple.replace_point_or_clone(1, "value «quux»").blueprint.should ==
        "value «quux» \n«quux»"
    end
  end
  
  
  
  describe "delete_point_or_clone" do
    before(:each) do
      @simple = Answer.new("block { do a do b do c do d do e}")
      @complicated = Answer.new("block { block {do a} do b block { block {do c} block {do d}} do e}")
    end
    
    
    it "should return a NudgeProgram (not an Answer)" do
      @simple.delete_point_or_clone(2).should be_a_kind_of(NudgeProgram)
    end
    
    it "should return a clone of the calling Answer's program if the point is out of bounds" do
      new_guy = @simple.delete_point_or_clone(-11)
      new_guy.blueprint.should == @simple.blueprint
      new_guy.object_id.should_not == @simple.program.object_id
      
      new_guy = @simple.delete_point_or_clone(1911)
      new_guy.blueprint.should == @simple.blueprint
    end
    
    it "should return a NudgeProgram with at least one fewer program points (if the range is OK)" do
      @complicated.delete_point_or_clone(2).points.should < @complicated.points
    end
    
    it "should delete the expected specific point (and any subpoints it has)" do
      @complicated.delete_point_or_clone(5).blueprint.should == 
        "block {\n  block {\n    do a}\n  do b\n  do e}"
    end
    
    it "should return NudgeProgram.new('block {}') when the entire program is deleted" do
      @complicated.delete_point_or_clone(1).blueprint.should == "block {}"
    end
    
    it "should delete the footnotes associated with a point it deletes" do
      a1 = Answer.new("block {value «a» value «b» value «c»}\n«a» 1\n«b» 2\n«c» 3")
      a1.delete_point_or_clone(3).blueprint.should ==
        "block {\n  value «a»\n  value «c»} \n«a» 1\n«c» 3"
    end
    
    it "should not delete extra footnotes" do
      a1 = Answer.new("block {value «a»}\n«a» 1\n«b» 2\n«c» 3")
      a1.delete_point_or_clone(2).blueprint.should ==
        "block {} \n«b» 2\n«c» 3"
    end
  end
  
  
  describe "locations" do
    describe "move_to" do
      it "should change the :location" do
        a = Answer.new("do a", location: :dzz)
        a.move_to(:zzd).location.should == :zzd
      end
      
      it "should raise an error if the argument isn't a Symbol" do
        lambda{Answer.new("do a").move_to(99123)}.should raise_error(ArgumentError)
      end
    end
  end
  
  
  describe "tags" do
    it "should have a tags array" do
      Answer.new("").tags.should be_a_kind_of(Set)
    end
    
    it "should be possible to set the tags upon initialization" do
      Answer.new("do a", tags:[:here, :now]).tags.should == Set.new([:here, :now])
    end
    
    it "should have an #add_tag method" do
      a1 = Answer.new("")
      a1.add_tag(:foo)
      a1.tags.should include(:foo)
    end
    
    it "should validate that tags being added are Symbols" do
      lambda{Answer.new("").add_tag("foo")}.should raise_error(ArgumentError)
    end
    
    it "should have an #remove_tag method" do
      a1 = Answer.new("", tags:[:a, :b])
      a1.tags.should include(:a)
      a1.remove_tag(:a)
      a1.tags.should_not include(:a)
    end
  end
end