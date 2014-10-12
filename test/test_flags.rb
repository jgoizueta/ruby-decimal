require File.expand_path(File.join(File.dirname(__FILE__),'helper.rb'))

class TestFlags < Test::Unit::TestCase

  def test_flags
    f = DecimalSupport::Flags(:flag_one, :flag_three)
    assert_equal "[:flag_one, :flag_three]",  f.to_a.sort_by{|flg| flg.to_s}.inspect
    f.values = DecimalSupport::FlagValues(:flag_one, :flag_two, :flag_three)
    assert_match /::Flags\[flag_one, flag_three\] \(0x5\)$/, f.inspect
    f[:flag_two] = true
    assert_match /::Flags\[flag_one, flag_two, flag_three\] \(0x7\)$/, f.inspect
    f[:flag_one] = false
    assert_match /::Flags\[flag_two, flag_three\] \(0x6\)$/, f.inspect
    f.clear!
    assert_match /::Flags\[\] \(0x0\)$/, f.inspect
    f << [:flag_one,:flag_two]
    assert_match /::Flags\[flag_one, flag_two\] \(0x3\)$/, f.inspect
    g = DecimalSupport::Flags(f.values)
    g.bits = f.bits
    assert_match /::Flags\[flag_one, flag_two\] \(0x3\)$/, g.inspect
    assert g==f
    g.set!
    assert_match /::Flags\[flag_one, flag_two, flag_three\] \(0x7\)$/, g.inspect
    assert g!=f

    assert DecimalSupport::Flags(:flag_one, :flag_three)==DecimalSupport::Flags(:flag_three, :flag_one)
    assert DecimalSupport::Flags(:flag_one, :flag_three)!=DecimalSupport::Flags(:flag_one)



  end

end
