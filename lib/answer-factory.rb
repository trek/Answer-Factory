$: << File.join(File.dirname(__FILE__), "/../lib") 

require 'rubygems'
require 'nudge'

require 'answers/answer'
require 'answers/batch'

require 'operators/basic_operators'
require 'operators/samplers_and_selectors'
require 'operators/evaluators'

require 'factories/factory'
require 'factories/workstation'

def AnswerFactory.gem_root
  File.dirname(__FILE__) + '/..'
end
