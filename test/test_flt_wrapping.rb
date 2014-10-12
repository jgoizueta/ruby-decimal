require File.expand_path(File.join(File.dirname(__FILE__),'helper.rb'))

class TestFltWrapping < Test::Unit::TestCase

  def test_flt_wrapping
    assert_equal Flt::DecNum, Decimal

    assert_equal Flt::DecNum('0.1'), Decimal('0.1')
  end

end

