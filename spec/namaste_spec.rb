require "namaste"
class TestNamasteSurrogate
  include Namaste::Mixin

  def test_make_namaste tag, value
    make_namaste tag, value
  end
end
describe Namaste do
  before(:all) do
    @namaste = TestNamasteSurrogate.new
  end
  it "should handle a simple value" do
    @namaste.test_make_namaste(0, 'abcdef').should == "0=abcdef"
  end
  it "should properly handle dflat" do
    @namaste.test_make_namaste(0, 'Dflat/0.19').should == "0=dflat_0.19"
  end
  it "should handle compled values correctly" do
    @namaste.test_make_namaste(0, 'rQ@f2!éüAsd!').should == "0=rq_f2_euasd_"
  end
  it "should handle extended integers correctly" do
    @namaste.test_make_namaste('x_123', 'extended').should == "x_123=extended"
  end
  it "should truncate file name at 255 characters" do
    namaste = @namaste.test_make_namaste(0, 'lfvtshfasfogfzjgqokuwicivlnyluqlgfcsfmhtdbmrizvzqkiyaxqtlclkgxpgkmxtwwylepsorbdnddgrdgzpcyojqbwuxkqkfzmfbkxrfpaaymgygbpjgqxyklkfblqekgtrpdxvjsmodvkrlwcfrqswdknngervsjivehotqeiowigfpwymunrccgjhakdwpugwwtpqcpkwqvwlhcqccwqovlwaldwfuoalscdvzccgnpooedbrnttzmno')
    namaste.length.should == 255
    namaste.should == '0=lfvtshfasfogfzjgqokuwicivlnyluqlgfcsfmhtdbmrizvzqkiyaxqtlclkgxpgkmxtwwylepsorbdnddgrdgzpcyojqbwuxkqkfzmfbkxrfpaaymgygbpjgqxyklkfblqekgtrpdxvjsmodvkrlwcfrqswdknngervsjivehotqeiowigfpwymunrccgjhakdwpugwwtpqcpkwqvwlhcqccwqovlwaldwfuoalscdvzccgnpooedbrnt...'
  end
end