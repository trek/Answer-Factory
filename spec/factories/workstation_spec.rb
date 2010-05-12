require File.join(File.dirname(__FILE__), "./../spec_helper")


describe "Workstation" do
  describe "#name" do
    it "should have a name" do
      Workstation.new(:my_workthing).name.should == :my_workthing
    end
    
    it "needs to have a symbol as a name" do
      lambda{Workstation.new("foo")}.should raise_error(ArgumentError)
      lambda{Workstation.new}.should raise_error(ArgumentError)
    end
    
    it "should have a factory_name" do
      Workstation.new(:ws).should respond_to(:factory_name)
    end
    
    it "should get factory_name from configatron" do
      configatron.temp do
        configatron.factory.name = 'somewhere_lovely'
        Workstation.new(:ws).factory_name.should == 'somewhere_lovely'
      end
    end
  end
  
  describe "couchdb views documents" do
    it "should respond to :couchdb_viewdoc" do
      Workstation.new(:foo).should respond_to(:couchdb_viewdoc)
    end
    
    it "should return a Hash" do
      Workstation.new(:foo).couchdb_viewdoc.should be_a_kind_of(Hash)
    end
    
    it "should have the right _id value" do
      Workstation.new(:foo).couchdb_viewdoc["_id"].should == "_design/foo"
    end
    
    it "should include the correct map code for this Workstation" do
      Workstation.new(:foo).couchdb_viewdoc[:views][:current][:map].should ==
        "function(doc) { if(doc.location == 'foo') { emit(doc._id, doc); } }"
    end
  end
  
  
  describe "capacity" do
    it "should accept a #capacity attribute in initialization" do
      w1 = Workstation.new(:ws, capacity:12)
      w1.capacity.should == 12
    end
    
    it "should have a default capacity of 100" do
       Workstation.new(:ws).capacity.should == 100
    end
  end
  
  
  describe "downstream_stations" do
    it "should have an Array attribute called #downstream_stations" do
      Workstation.new(:place).downstream_stations.should be_a_kind_of(Array)
    end
    
    it "#downstream_stations should default to an empty Array" do
      Workstation.new(:place).downstream_stations.should == []
    end
  end
  
  
  describe "answers" do
    it "should be a Batch that's empty initially" do
      Workstation.new(:place).answers.should be_a_kind_of(Batch)
    end
  end
  
  
  describe "transfer_answer" do
    before(:each) do
      @a1 = Answer.new("do a", tags:[:here])
      @w1 = Workstation.new(:here)
    end
    
    it "should change the location tag of the Answer by removing self.name and adding destination.name" do
      @w1.transfer_answer(@a1, :there)
      @a1.tags.should include(:there)
      @a1.tags.should_not include(:here)
    end
    
    it "should validate that the new location (tag) is a Symbol" do
      lambda{@w1.transfer_answer(@a1, "garbage")}.should raise_error(ArgumentError)
    end
    
    it "should not change state if the ne location name is invalid" do
      lambda{@w1.transfer_answer(@a1, "garbage")}.should raise_error(ArgumentError)
      @a1.tags.should include(:here)
    end
  end
  
  
  
  describe "#cycle" do
    before(:each) do
      FakeWeb.register_uri(:any, "http://127.0.0.1:5984/this_factory/_bulk_docs",
        :body => @canned, :status => [200, "OK"])
    end
    
    it "should invoke #receive!, #build!, #ship!, #scrap! and #after_cycle!" do
      configatron.temp do
        configatron.factory.couchdb.server = "http://127.0.0.1:5984"
        configatron.factory.couchdb.name = "this_factory"
        
        w1 = Workstation.new(:this_factory)
        w1.stub!(:after_cycle!)
        w1.should_receive(:receive!)
        w1.should_receive(:build!)
        w1.should_receive(:ship!)
        w1.should_receive(:scrap!)
        w1.should_receive(:after_cycle!)
        w1.cycle
      end
    end
    
    describe "the #after_cycle method" do
      it "should save everything in @answers to the persistent store" do
        configatron.temp do
          configatron.factory.couchdb.server = "http://127.0.0.1:5984"
          configatron.factory.couchdb.name = "this_factory"
          
          FakeWeb.allow_net_connect = false
          @w1 = Workstation.new(:ws1, factory_name:"this_factory")
          @w1.answers.should_receive(:bulk_save!)
          @w1.after_cycle!
        end
      end
    end
    
    describe "#receive!" do
      # the superclass we're testing (Workstation) should do nothing here,
      # but there are some helper methods defined for use in subclasses;
      # we should test those
      
      describe "gather_mine" do
        before(:each) do
          @w1 = Workstation.new(:ws1, factory_name:"this_factory")
          
          @uri = "http://127.0.0.1:5984/this_factory"
          @design_doc = "ws1/current"  # we'll assume this has been set up!
          @view_uri = "http://127.0.0.1:5984/this_factory/_design/ws1/_view/current"
          FakeWeb.allow_net_connect = false
          @canned = '{"total_rows":1,"offset":0,"rows":[{"id":"0f60c293ad736abfdb083d33f71ef9ab","key":"ws1","value":{"_id":"0f60c293ad736abfdb083d33f71ef9ab","_rev":"1-473467b6dc1a4cba3498dd6eeb8e3206","blueprint":"do bar","tags":[],"scores":{"badness": 12.345},"progress":12,"timestamp":"2010/04/14 17:09:14 +0000"}}]}'
        end
        
        it "should use the Batch#load_from_couch method" do
          configatron.temp do
            configatron.factory.couchdb.server = "http://127.0.0.1:5984"
            configatron.factory.couchdb.name = "this_factory"
            
            FakeWeb.register_uri(:any, @view_uri, :body => @canned, :status => [200, "OK"])
            Batch.should_receive(:load_from_couch).with(@uri,@design_doc).and_return(Batch.new)
            @w1.gather_mine
          end
        end
        
        it "should add that Batch into self#answers" do
          configatron.temp do
            configatron.factory.couchdb.server = "http://127.0.0.1:5984"
            configatron.factory.couchdb.name = "this_factory"
          
            FakeWeb.register_uri(:any, @view_uri, :body => @canned, :status => [200, "OK"])
            @w1.answers.length.should == 0
            @w1.gather_mine
            @w1.answers.length.should == 1
            @w1.answers[0].scores[:badness].should == 12.345
          end
        end
      end
      
      
      describe "gather_into" do
      end
    end
    
    
    describe "#build!" do
      # the superclass we're testing (Workstation) should do nothing here,
      # but there are some helper methods defined for use in subclasses;
      # we should test those
      
      describe "process_with" do
        before(:each) do
          @w1 = Workstation.new(:pity_foo)
          @w1.answers = Batch[Answer.new("block{}")]
          @sampler = Machines::SampleAnyOne.new
        end
        
        it "should accept one parameter" do
          @w1.method(:process_with).arity.should == 1
        end
        
        it "should only accept a search operator" do
          lambda{@w1.process_with(8)}.should raise_error(ArgumentError)
          lambda{@w1.process_with(@sampler)}.should_not raise_error
        end
        
        it "should call the search operator's '#generate" do
          @sampler.should_receive(:generate)
          @w1.process_with(@sampler)
        end
        
        it "should pass in self#answers to the call to #generate" do
          @sampler.should_receive(:generate).with(@w1.answers)
          @w1.process_with(@sampler)
        end
        
        it "should return a Batch" do
          @w1.process_with(@sampler).should be_a_kind_of(Batch)
        end
      end
    end
    
    
    describe "#ship!" do
      # the superclass we're testing (Workstation) should do nothing here,
      # but there are some helper methods defined for use in subclasses;
      # we should test those
      
      describe "ship_to" do
        before(:each) do
          @w2 = Workstation.new(:lulu)
          @a1 = Answer.new("do fun_stuff", location: :lulu)
          @a2 = Answer.new("do sad_stuff", location: :lulu)
          @w2.answers = Batch[@a1,@a2]
        end
        
        
        it "should accept a single argument" do
          @w2.method(:ship_to).arity.should == 1
        end
        
        it "should be comfortable without any block" do
          @w2.ship_to(:here)
        end
        
        it "should check the argument is a symbol" do
          lambda{@w2.ship_to(8)}.should raise_error(ArgumentError)
          lambda{@w2.ship_to(:heaven)}.should_not raise_error
        end
        
        it "should pass every element of @answers into the associated block" do
          Math.should_receive(:sin).exactly(2).times
          @w2.ship_to(:heaven) {|a| Math.sin(12.0)}
        end
        
        it "should change the :location of the answers in the filtered subset" do
          @a1.should_receive(:move_to).with(:xyzzy)
          @a2.should_receive(:move_to).with(:xyzzy)
          @w2.ship_to(:xyzzy) {|a| true}
        end
        
        it "should only ship things that are still there" do
          @a2.location = :far_away
          @w2.ship_to(:other_place) {|a| true}
          @a2.location.should == :far_away
        end
      end
    end
    
    
    describe "scrap!" do
      
      # the superclass we're testing (Workstation) should do nothing here,
      # but there are some helper methods defined for use in subclasses;
      # we should test those
      
      describe "scrap_if" do
        before(:each) do
          @w3 = Workstation.new(:falafel)
          @a1 = Answer.new("do fun_stuff", progress:1, location: :falafel)
          @a2 = Answer.new("do sad_stuff", progress:99, location: :falafel)
          @w3.answers = Batch[@a1,@a2]
        end
        
        it "should accept a single argument" do
          @w3.method(:scrap_if).arity.should == 1
        end
        
        it "should pass every element of @answers into a block" do
          Math.should_receive(:cos).exactly(2).times
          @w3.scrap_if("Math says so") {|a| Math.cos(12.0)}
        end
        
        it "should not scrap things that aren't at that location"
      end
      
      describe "scrap_everything" do
        before(:each) do
          @w4 = Workstation.new(:ice_station_zebra)
          @a1 = Answer.new("do anything", location: :ice_station_zebra)
          @a2 = Answer.new("do whatevz", location: :ice_station_zebra)
          @w4.answers = Batch[@a1,@a2]
        end
        
        it "should have arity 0" do
          @w4.method(:scrap_everything).arity.should == 0
        end
        
        it "should call scrap_if" do
          @w4.should_receive(:ship_to)
          @w4.scrap_everything
        end
        
        it "should send every answer to :SCRAP" do
          @w4.answers.each {|a| a.location.should_not == :SCRAP}
          @w4.scrap_everything
          @w4.answers.each {|a| a.location.should == :SCRAP}
        end
        
        it "should be safe to repeat the statement" do
          @w4.scrap_everything
          lambda{@w4.scrap_everything}.should_not raise_error
        end
        
        it "should not scrap things that aren't at that location"
        
      end
    end
  end
end