# sets expectation for Array#sample calls and returned indexes
# array_sample(5,5,5).returns([],[],[])
class MockArraySample
  def self.shared_instance=(mock_sample)
    @instance = mock_sample
  end
  
  def self.return_value_from_mocks(expected_argument)
    @instance.return_value_from_mocks(expected_argument)
  end
  
  def initialize(args)
    @argument_expectations = args
    MockArraySample.shared_instance = self
    @index = 0
  end
  
  def and_return(*arrays)
    @returns = arrays
    self
  end
  
  def return_value_from_mocks(expected_argument)
    sample = @returns[@index]
    @index += 1
    if @index == @returns.size
      ::Array.module_eval { alias :sample :stored_sample_method }
    end
    sample
  end
end

def mock_every_array_sample(*args)
  ::Array.module_eval do
    alias :stored_sample_method :sample
    def sample(n = 1)
      indices = MockArraySample.return_value_from_mocks(n)
      if indices.kind_of?(Array)
        indices.collect {|i| self.at(i) }
      else
        self.at(indices)
      end
    end
  end
  
  MockArraySample.new(args)
end
