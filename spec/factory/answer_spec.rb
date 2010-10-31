require File.dirname(__FILE__) + '/../spec_helper'

describe "Answer" do
  #(id, blueprint, location, origin, parent_ids, created, archived)
  before(:each) do
    @blueprint = FakeBlueprint.new
    @answer = Answer.new(Guid.id, @blueprint, nil, nil, nil, nil, nil)
  end
  
  it 'obtains its language from the language of its blueprint' do
    @answer.language.should == :Fake
  end
  
  describe 'score values' do
    before(:each) do
      @answer.instance_variable_set("@scores", {:awesomeness => Score.new('awesomeness', 5, 0, nil, nil)})
    end
    
    it 'retrived by name if score exists' do
      @answer.get_score(:awesomeness).should == 5
    end
    
    it 'default to Factory::Infinity if there is no score by that name' do
      @answer.get_score(:lameitude).should == Factory::Infinity
    end
  end
  
  describe 'dominated state' do
    it 'is non-dominated if all of the compared answer\'s scores are identical for the listed criteria' do
      answer = answer_factory('', running: 5, swimming: 5)
      another_answer = answer_factory('', running: 5, swimming: 5) # <- identically skilled swimmer, runner
            
      answer.nondominated_vs?(another_answer, [:swimming,:running]).should == true
    end
    
    it 'is dominated if any of the compared answer\'s scores for any listed criteria is better' do
      answer = answer_factory('', running: 5, swimming: 10)
      another_answer = answer_factory('', running: 5, swimming: 1) # <- better swimmer
            
      answer.nondominated_vs?(another_answer, [:swimming,:running]).should == false
    end
    
    it 'is non-dominated if all scores of the comapred answer for all listed criteria are worse' do
      answer = answer_factory('', running: 5, swimming: 2) # <- better swimmer
      another_answer = answer_factory('', running: 5, swimming: 5)
      
      answer.nondominated_vs?(another_answer, [:running,:swimming]).should == true
    end
  
    it 'is non-dominated if all scores of the comapred answer are worse for listed criteria even if unlisted criteria are better' do
      another_answer = answer_factory('', running: 5, swimming: 5, biking: 1) # <- very good at biking, but we don't care
      answer = answer_factory('', running: 5, swimming: 1, biking: 40) # <- best at swimming, miserable biker
      
      answer.nondominated_vs?(another_answer, [:running,:swimming]).should == true
    end
  end
end