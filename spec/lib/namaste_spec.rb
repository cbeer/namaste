require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
  describe "make_namaste" do
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

  describe "object instantiation" do
    it "should define the appropriate setters and getters" do
      d = Dir.mktmpdir
      dir = Namaste::Dir.new(d)
      dir.respond_to?(:type).should be_true
      dir.respond_to?(:type=).should be_true
      dir.respond_to?(:who).should be_true
      dir.respond_to?(:who=).should be_true
      dir.respond_to?(:what).should be_true
      dir.respond_to?(:what=).should be_true
      dir.respond_to?(:when).should be_true
      dir.respond_to?(:when=).should be_true
      dir.respond_to?(:where).should be_true
      dir.respond_to?(:where=).should be_true
    end
  end
  describe "namaste_tags" do
    it "should handle normal filters correclty" do
      Dir.mktmpdir do |d|
        dir = Namaste::Dir.new(d)
        File.open(File.join(dir.path,"1=last,first"),"w") do |f|
          f.write("Last,First")
        end
        dir.send(:namaste_tags,{:filter=>"1"}).include?("1=last,first").should be_true
      end
    end
    it "should take regular expressions correctly" do
      Dir.mktmpdir do |d|
        dir = Namaste::Dir.new(d)
        File.open(File.join(dir.path,"1=last,first"),"w") do |f|
          f.write("Last,First")
        end
        dir.send(:namaste_tags,{:regex=>/last,first/}).include?("1=last,first").should be_true
      end
    end
    it "should take a number as a regexp and handle it correclty" do
      Dir.mktmpdir do |d|
        dir = Namaste::Dir.new(d)
        File.open(File.join(dir.path,"1=last,first"),"w") do |f|
          f.write("Last,First")
        end
        dir.send(:namaste_tags,{:filter=>:who}).include?("1=last,first").should be_true
      end
    end
  end
  
  describe "get_namaste" do
    it "should reterive the appriprate tag" do
      Dir.mktmpdir do |d|
        dir = Namaste::Dir.new(d)
        File.open(File.join(dir.path,"1=last,first"),"w") do |f|
          f.write("Last,First")
        end
        data = dir.send(:get_namaste,"1=last,first")
        data.has_key?(:value).should be_true and
        data[:value].should == "Last,First"
        
        data.has_key?(:file).should be_true and
        data[:file].should == "1=last,first"
        
        data.has_key?(:name).should be_true and
        data[:name].should == "1"
      end
    end
  end

  describe "dirtype" do
    it "should parse out the Dflat type properly" do
      Dir.mktmpdir do |d|
        dir = Namaste::Dir.new(d)
        File.open(File.join(dir.path,"0=dflat_0.19"),"w") do |f|
          f.write("Dflat/0.19")
        end
        dir.dirtype.length == 1
        
        dir.dirtype.first.has_key?(:name).should be_true and
        dir.dirtype.first[:name].should == "Dflat"
        
        dir.dirtype.first.has_key?(:minor).should be_true and
        dir.dirtype.first[:minor].should == "19"
        
        dir.dirtype.first.has_key?(:type).should be_true and
        dir.dirtype.first[:type].should == "Dflat/0.19"
        
        dir.dirtype.first.has_key?(:major).should be_true and
        dir.dirtype.first[:major].should == "0"
      end
    end
  end
  
end