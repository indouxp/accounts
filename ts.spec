# coding:utf-8
require 'rubygems'
require 'rspec'
describe "test"do
  it "ex1" do # 「should raise_error」で# procを実行した際に何らかの例外が発生することを確認できる
    proc {
      raise"test"
    }.should raise_error
    
    # 例外の型やmessageを評価することも可能。
    proc {
      raise IOError.new( "test" )
    }.should raise_error( IOError )
    proc {
      raise IOError.new( "test" )
    }.should raise_error( IOError, "test" )
    proc {
      raise IOError.new( "test" )
    }.should raise_error( IOError, /t.*/ )
    
    # ブロックを指定することでさらに詳細なチェックも可能
    proc {
      ex = IOError.new( "test" )
      class << ex
        def var; "aaa"end
      end
      raise ex
    }.should raise_error( IOError, "test" ) {|ex|
      ex.var.should == "aaa"
    }
  end
end
