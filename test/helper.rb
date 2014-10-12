require 'test/unit'
$: << "." unless $:.include?(".") # for Ruby 1.9.2
require File.expand_path(File.join(File.dirname(__FILE__),'/../lib/decimal'))

def initialize_context
  Decimal.context = Decimal::ExtendedContext
end
