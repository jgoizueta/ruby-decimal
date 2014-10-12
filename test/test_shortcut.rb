require File.expand_path(File.join(File.dirname(__FILE__),'helper.rb'))

require 'decimal/shortcut'

class TestShortcut < Test::Unit::TestCase

  def test_shortcut
    assert_equal Decimal('0.1'), D('0.1')
  end

end
