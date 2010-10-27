module Matchers
  class HaveAnswers
    def initialize(*expected)
      @expected_answers = expected
    end
    
    def evolved_by(*how)
      @changes = how
      @compare_child_answers = true
      self
    end
    
    def evolved
      self.evolved_by
    end
    
    def in_location(label)
      @labeled = label
      self
    end
    
    def once
      @exact_number_of_created = 1
      self
    end
    
    def twice
      @exact_number_of_created = 2
      self
    end
    
    def matches?(factory)
      @actual = factory.instance_variable_get("@latest_saved_answers_by_location")[@labeled.to_sym]
      
      if @compare_child_answers
        @difference = []
        @expected_answers.each do |expected|
          found = @actual.select do |a|
            if @changes
              a.parent_ids == [expected.id] && a.blueprint.changes == @changes
            else
              a.parent_ids == [expected.id]
            end
          end
          
          if @exact_number_of_created
            @difference << expected unless found.size == @exact_number_of_created
          else
            @difference << expected unless found.first
          end
        end
                
        return @difference.empty?
      end
      
      @difference = []
      @expected_answers.each do |expected|
        @difference << expected unless @actual.include?(expected)
      end
      
      @difference.empty?
    end
    
    def failure_message
      "expected '#{@expected_answers}' but got '#{@actual}' \nDifference: #{@difference}"
    end
    
    def negative_failure_message
      "expected something else than '#{@expected_answers}' but got '#{@actual}'. \nDifference: #{@difference}"
    end
  end
end
def have_answers(*expected)
  Matchers::HaveAnswers.new(*expected)
end