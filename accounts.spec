# coding:utf-8
require 'rubygems'
require 'rspec'
require './accounts.rb'

describe '補完テスト' do
  before(:each) do
    @rec = Record.new
  end
  context 'YYYY/MM/DD' do
    ymd = '2011/1/1'
    it ymd do
      proc do
        result = @rec.complement_date(ymd)
        result.should eq('2011/01/01')
      end
    end
    ymd = '1/1'
    it ymd do
      proc do
        result = @rec.complement_date(ymd)
        result.should eq('2011/01/01')
      end
    end
    ymd = '2011/01/01'
    it ymd do
      proc do
        result = @rec.complement_date(ymd)
        result.should eq(ymd)
      end
    end
    ymd = '2011/02/31'
    it ymd do
      proc do
        result = @rec.complement_date(ymd)
        result.should raise_error(RuntimeError, ymd + "は日付として妥当ではありません。")
      end
    end
    ymd = '02/30'
    it ymd do
      proc do
        result = @rec.complement_date(ymd)
        result.should raise_error(RuntimeError, ymd + "は日付として妥当ではありません。")
      end
    end
  end 
  after(:each) do
    @rec = nil
  end
end
