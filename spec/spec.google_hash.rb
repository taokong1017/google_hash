require 'rubygems'
require 'sane'
require_relative '../ext/google_hash'
begin
  require 'spec/autorun'
rescue LoadError
  require 'rspec' # rspec2
end

describe "google_hash" do

  before do
   @subject = GoogleHashSparseIntToRuby.new
  end

  it "should be instantiable [new method should not raise]" do
    GoogleHashSparseIntToRuby.new
  end

  it "should allow you to set a key" do
    @subject[33] = 'abc'
  end

  it "should allow you to retrieve a key" do
    @subject[33] = 'abc'
    @subject[33].should == 'abc'
  end

  it "should allow you to iterate" do
   @subject[33] = 'abc'
   @subject[44] = 'def'
   all_got = []
   @subject.each{|k, v|
    all_got << v
   }
   assert all_got.sort == ['abc', 'def']
  end

  it "should have key methods" do
    @subject = a = GoogleHashDenseDoubleToInt.new
    @subject[33] = 3
    for method in [:has_key?, :include?, :key?, :member?] do
      @subject.send(method, 33).should == true
      @subject.send(method, 34).should == false
    end
    
  end
  
  it "should have all the methods desired" do
    # guess these could all be tests, themselves...
    @subject.each{}
    @subject[33] = 'abc'
    @subject.length.should == 1
    @subject.each{}
    @subject.each{|k, v|
      k.should == 33
      v.should == 'abc'
    }
    @subject.delete(33).should == 'abc'
    @subject.length.should == 0
    @subject[33] = 'abc'
    @subject.length.should == 1
    @subject.clear
    @subject.length.should == 0
  end
  
  it 'should not be able to set the absent key for double' do
    fail
  end

  def populate(a)
    a['abc'] = 'def'
    a['bbc'] = 'yoyo'
  end
  
  it "should not die with GC" do
    a = GoogleHashSparseRubyToRuby.new
    populate(a)
    a['abc'].should == 'def'
    a['bbc'].should == 'yoyo'
    GC.start
    a.keys.each{|k| k}
    a.values.each{|v| v}
  end
    

  it "should work with value => value" do
    a = GoogleHashSparseRubyToRuby.new
    a['abc'] = 'def'
    a['abc'].should == 'def'
    a = GoogleHashDenseRubyToRuby.new
    a['abc'] = 'def'
    a['abc'].should == 'def'
  end

  it "should have better namespace" do
    pending do
      GoogleHash::Sparse
    end
  end

  it "should disallow non numeric keys" do
    lambda { @subject['33']}.should raise_error(TypeError)
  end

#  it "should allow for non numeric keys" do
    # todo instantiate new type here...
    # todo allow for floats, ints, symbols, strings [freeze 'em]
    # wait are any of those actually useful tho?
#    @subject['33'] = 33
#    @subject['33'].should == 33
#  end

  it "should return nil if key is absent" do
    @subject[33].should be_nil
  end

  it "should work with 0's" do
   @subject[0] = 'abc'
   @subject[0].should == 'abc'
  end

  it "should do BigNums" do
    pending "if necessary"
  end

  it "should do longs" do
    GoogleHashDenseLongToLong.new
  end

  if OS.bits == 64
    it "should disallow keys like 1<<40 for ints on 64 bit"
  end

  it "should have sets"
  it "should have Set#each"

  it "Set should have #combination calls" do
    @subject[33] = 34
    @subject[36] = 37
    @subject.keys_combination_2{|a, b|
      assert a == 33
      assert b == 36
    }
    
  end
  
  it "Set should have #combination calls with more than one" do
    @subject[1] = 34
    @subject[2] = 37
    @subject[3]= 39
    sum = 0
    count = 0
    @subject.keys_combination_2{|a, b|
      sum += a
      sum += b
      count += 1
    }
    assert count == 3
    assert sum == 1 + 2 + 1 + 3 + 2 + 3
  end

  it "should have an Array for values, keys" do
    @subject[33] = 34
    @subject.keys.should == [33]
    @subject.values.should == [34]
  end
  
  it "should work with all Longs" do
    a = GoogleHashDenseIntToInt.new
    a[3] = 4
    a[3].should == 4
  end
  
  it "should raise on errant values" do
    a = GoogleHashDenseIntToInt.new
    proc { a[3] = 'abc'}.should raise_error
  end
  
  it "should do bignum values as doubles" do
    a = GoogleHashDenseDoubleToInt.new
    a[10000000000000000000] = 1
    a[10000000000000000000].should == 1
  end
  
  it "should not leak" do
    pending 'something that might leak'
    a = GoogleHashDenseIntToInt.new
    100_000.times {
      a[1] = 1
      a[1]
      a.each{|k, v|}
      a.delete(1) rescue nil
    }
    OS.rss_bytes.should be < 25_000_000
  end
  
  it "should do int values as doubles" do
    a = GoogleHashDenseDoubleToInt.new
    a[1] = 1
    a[1].should == 1
  end

  it "should do float values as doubles" do
    pending "interest in floats"
    a = GoogleHashDenseDoubleToInt.new
    a[1.0] = 1
    a[1.0].should == 1
  end
  
  it "should do bignum to doubles et al" do
    a = GoogleHashDenseDoubleToDouble.new
    a[10000000000000000000] = 1
    a[10000000000000000000].should == 1
    a[1] = 10000000000000000000
    a[1].should == 10000000000000000000
    a[4] = 3
    a[4].should == 3
    a[10000000000000000000] = 10000000000000000000
    a[10000000000000000000].should == 10000000000000000000
  end
  
  it "should allow for storing true bignums" do
    pending
    fail 'same as above plus the following:'
    a = GoogleHashDenseBignumToRuby.new
    a[10000000000000000000] = 'abc'
  end
  
  it 'should be able to delete bignums without leaking' do
    pending
    a = GoogleHashDenseBignumToBignum.new
    100_000.times {
      a[10000000000000000000] = 1
      a.size.should == 1
      a.delete[10000000000000000000]
      a.size.should == 0
    }
    assert OS.rss_bytes < 100_000
  end
  
  it "should have an Enumerator for values, keys, an on demand, getNext enumerator object..."
  
  it "should have a block access for values, keys" do
    pending "interest"
    @a[3] = 4
    a.each_value {}
    a.each_key {}
  end
  
  it "should have nice inspect" do
    a = GoogleHashSparseIntToRuby.new
    a[3] = 4
    a[4] = 5
    a.inspect.should == "GoogleHashSparseIntToRuby {3=>4,4=>5}"
  end
  
  it "should have sets, too, not just hashes"
  
  it "should skip GC when native to native" do
    # tough to test...
  end
  
  it "should allow for setting the right keys" do
    all_classes = Object.constants.grep(/googlehash/i).map{|c| Object.const_get(c) }
    all_classes.select{|c| c.to_s =~ /(int|long)to/i}.each{|c| 
      p c
      keys = [0, 1, -1, 1<<29]
      if OS.bits == 64
       keys << (1<<61)
      end
      keys.each{|k|
        instance = c.new
        instance[k] = 0
        instance[k].should == 0
      }
    }
  end

end
