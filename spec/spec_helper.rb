require File.join(File.dirname(__FILE__), '..', 'answer_factory')
Dir.glob(File.dirname(__FILE__) + '/helpers/*') {|file| require file }
Dir.glob(File.dirname(__FILE__) + '/matchers/*') {|file| require file }
require 'spec'

# Spec::Runner.configure do |config|
#   config.mock_with :mocha
# end

class Factory  
  def self.reset
    @workstations = nil
    @schedule = nil
  end
end