module AnswerFactory
  module Machines
    
    class Machine
      
      attr_reader :options
      
      def initialize(options = {})
        @options = options
      end
    end
    
  end
end