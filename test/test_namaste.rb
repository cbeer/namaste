require 'helper'

class TestNamasteSurrogate
  include Namaste::Mixin

  def test_make_namaste tag, value
    make_namaste tag, value
  end
end
class TestNamaste < Test::Unit::TestCase
  def test_make_simple
    t = TestNamasteSurrogate.new
    assert_equal(t.test_make_namaste(0, 'abcdef'), '0=abcdef')
  end

  def test_make_dflat
    t = TestNamasteSurrogate.new
    assert_equal(t.test_make_namaste(0, 'Dflat/0.19'), '0=dflat_0.19')
  end

  def test_make_complex
    t = TestNamasteSurrogate.new
    assert_equal(t.test_make_namaste(0, 'rQ@f2!éüAsd!'), '0=rq_f2_euasd_')
  end

  def test_make_extended
    t = TestNamasteSurrogate.new
    assert_equal(t.test_make_namaste('x_123', 'extended'), 'x_123=extended')
  end

  def test_truncate
    t = TestNamasteSurrogate.new
    assert_equal(t.test_make_namaste(0, 'lfvtshfasfogfzjgqokuwicivlnyluqlgfcsfmhtdbmrizvzqkiyaxqtlclkgxpgkmxtwwylepsorbdnddgrdgzpcyojqbwuxkqkfzmfbkxrfpaaymgygbpjgqxyklkfblqekgtrpdxvjsmodvkrlwcfrqswdknngervsjivehotqeiowigfpwymunrccgjhakdwpugwwtpqcpkwqvwlhcqccwqovlwaldwfuoalscdvzccgnpooedbrnttzmno'), '0=lfvtshfasfogfzjgqokuwicivlnyluqlgfcsfmhtdbmrizvzqkiyaxqtlclkgxpgkmxtwwylepsorbdnddgrdgzpcyojqbwuxkqkfzmfbkxrfpaaymgygbpjgqxyklkfblqekgtrpdxvjsmodvkrlwcfrqswdknngervsjivehotqeiowigfpwymunrccgjhakdwpugwwtpqcpkwqvwlhcqccwqovlwaldwfuoalscdvzccgnpooedbrnt...')
  end
end
