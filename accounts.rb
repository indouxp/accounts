#!/usr/bin/env ruby
# coding:utf-8
#
require './item.rb'

#
#
#
class Record
  $msgs = {0=>"年月日", 1=>"科目コード", 2=>"取引金額", 3=>"適用", 4=>"支払先など"}
  attr_accessor :item, :sum_of_money, :date, :application, :payee
  def initialize
    @item = nil         # 科目
    @sum_of_money = nil # 金額
    @date = nil         # 日付
    @application = nil  # 適用
    @payee = nil        # 支払先
  end
  #
  # Recordに、s_inを追加
  #
  def add(item_code, s_in)
    case
    when s_in =~ /\d{4}?\/?\d{2}\/\d{2}/ # 年月日
      @date = s_in
      message("日付:#{@date}")
      true
    when s_in =~ /^\d{4}$/                # 科目
      result =  item_code.check(s_in) 
      if result != nil
        @item = s_in
        message("科目:#{result}")
      else
        @sum_of_money = s_in.to_i
        message("金額:#{@sum_of_money.to_s}")
      end
      true
    when s_in =~ /^\\\d+$/
      @sum_of_money = s_in.sub(/^\\/, "").to_i
      message("金額:#{@sum_of_money.to_s}")
      true
    when s_in =~ /^\d+$/
      @sum_of_money = s_in.to_i
      message("金額:#{@sum_of_money.to_s}")
      true
    else
      result = false
      while true
        message("#{s_in}\n> a:適用, p:支払先 c:Cancel ?:", true)
        s_which = gets.chomp
        case s_which
        when "a"
          @application = s_in
          result = true
          break
        when "p"
          @payee = s_in
          result = true
          break
        when "c"
          break
        end
      end
      result
    end  
  end
end

def display_rec(rec, item_code)
  puts "日付  :Date       :#{rec.date}"
  puts "科目  :Item       :#{rec.item}:#{item_code.check(rec.item)}" 
  puts "金額              :#{rec.sum_of_money}"
  puts "適用  :Application:#{rec.application}"
  puts "支払先:Payee      :#{rec.payee}"
end

def message(str, question=false)
  if question
    STDERR.print(str)
  else
    STDERR.puts(str)
  end
end

class Help
  def initialize(item_code)
    @items = item_code.items
    @done = true
    @now = 0
    @lines = 10
  end

  def lookup(s_code)
    message("#{s_code}:#{@items[s_code]}")
  end

  def out
    if @done
      @now = 0
    end
    count = 0
    index = 0
    @items.each_pair do |key, value|
      if @now <= index
        if count <= @lines
          message("#{key}:#{value}")
          @now = index
          count += 1
        end
      end
      index += 1
    end
    if (@items.size) -1 == @now
      @done = true
    else
      @done = false
    end
    message("size:#{@items.size} now:#{@now} index:#{index} count:#{count} done:#{@done}")
  end
end

def clear(rec)
  rec.date = nil
  rec.item = nil
  rec.sum_of_money = nil
  rec.application = nil
  rec.payee = nil
end

def display_recs(recs)
  recs.each do |rec|
    puts rec
  end
end

def ok(recs, rec)
  recs.push("#{rec.date},#{rec.item},#{rec.sum_of_money},#{rec.application},#{rec.payee}")
  clear(rec)
  rec = nil
  rec = Record.new
end

if __FILE__ == $0
  item_code = ItemCode.new("./item.txt")
  recs = []
  help = Help.new(item_code)
  data_file = "./accounts.dat"
  File.open(data_file) do |f|
    f.each do |line|
      recs.push(line.chomp)
    end
  end
  rec = Record.new
  while true
    print "> "
    s_in = gets.chomp
    case
    when s_in =~ /(^all print$|^a$)/
      display_recs(recs)
    when s_in =~ /(^print$|^p$)/
      display_rec(rec, item_code)
    when s_in =~ /(^quit$|^q$)/
      break
    when s_in =~ /(^help$|^h$)/
      help.out
    when s_in =~ /(^help \d+$|^h \d+$)/
      help.lookup(s_in.sub(/^h\S*\s+/, ""))
    when s_in =~ /(^ok$|^add$)/
      ok(recs, rec)
    else
      if ! rec.add(item_code, s_in)
        message("ERROR")
        print
      end
    end
  end
  display_recs(recs)
  File.open(data_file, "w") do |f|
    recs.each do |line|
      f.puts(line)
    end
  end
end
exit(0)