#!/usr/bin/env ruby
# coding:utf-8
#
require './item.rb'

#
#
#
class Record
  require 'date'
  attr_accessor :item, :receive_money, :payment_money, :date, :summary, :payee
  def initialize
    @date = nil          # 日付
    @item = nil          # 科目
    @receive_money = nil # 入金金額
    @payment_money = nil # 出金金額
    @summary = nil       # 摘要
    @payee = nil         # 支払先
  end
  def ok?
    if @item != nil && 
      @receive_money != nil &&
      @payment_money != nil &&
      @date != nil
      true
    else
      false
    end
  end

  #
  #
  #
  def complement_date(s, year)
    year = Time.now.year.to_s if year == nil || year == ""
    begin
      ymds = s.split(/\//)
      case ymds.size
      when 3
        d_result = Date.new(ymds[0].to_i, ymds[1].to_i, ymds[2].to_i)
      when 2
        d_result = Date.new(year.to_i, ymds[0].to_i, ymds[1].to_i)
      else
        raise "#{s}は日付として妥当ではありません。"
      end
      result = d_result.strftime("%Y/%m/%d")
      return result
    rescue
      raise "#{s}は日付フォーマットではありません。"
    end
  end
  #
  # Recordに、s_inを追加
  #
  def add(item_code, s_in, i_year)
    case
    when s_in =~ /\d{4}?\/?\d{1,2}\/\d{1,2}/ # 年月日
      @date = self.complement_date(s_in, i_year)
      message("日付:#{@date}")
      true
    when s_in =~ /^\d{4}$/                # 科目
      result =  item_code.check(s_in) 
      if result != nil
        @item = s_in
        message("科目:#{result}")
      else
        @receive_money = s_in.to_i      # 入金金額
        @payment_money = 0              # 出金金額
        message("入金金額:#{@receive_money}")
        message("出金金額:#{@payment_money}")
      end
      true
    when s_in =~ /^\\-?\d+$/
      money = s_in.sub(/^\\/, "").to_i
      if money < 0
        @payment_money = money * -1
        @receive_money = 0
      else
        @receive_money = money
        @payment_money = 0
      end
      message("入金金額:#{@receive_money}")
      message("出金金額:#{@payment_money}")
      true
    when s_in =~ /^-?\d+$/
      money = s_in.to_i
      if money < 0
        @payment_money = money * -1
        @receive_money = 0
      else
        @receive_money = money
        @payment_money = 0
      end
      message("入金金額:#{@receive_money}")
      message("出金金額:#{@payment_money}")
      true
    else
      result = false
      while true
        message("#{s_in}\n> s:摘要, p:支払先 c:Cancel ?:", true)
        s_which = STDIN.gets.chomp
        case s_which
        when "s"
          @summary = s_in
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
  puts "日付  :Date   :#{rec.date}"
  puts "摘要  :Summary:#{rec.summary}"
  puts "支払先:Payee  :#{rec.payee}"
  puts "科目  :Item   :#{rec.item}:#{item_code.check(rec.item)}" 
  puts "入金金額      :#{rec.receive_money}"
  puts "出金金額      :#{rec.payment_money}"
end

def message(str, question=false)
  if question
    STDERR.print(str)
  else
    STDERR.puts(str)
  end
end

class Item
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
  end
end

def clear(rec)
  rec.date = nil
  rec.item = nil
  rec.receive_money = nil
  rec.payment_money = nil
  rec.summary = nil
  rec.payee = nil
end

def display_recs(recs, start_money)
  puts "期首残高:#{start_money}"
  balance_money = start_money
  recs.each do |rec|
    fields = rec.split(/,/)
    balance_money = balance_money - fields[4].to_i + fields[5].to_i
    puts "#{rec} :#{balance_money}"
  end
end

def ok(recs, rec)
  recs.push("#{rec.date},#{rec.summary},#{rec.payee},#{rec.item},#{rec.payment_money},#{rec.receive_money}")
  clear(rec)
  rec = nil
  rec = Record.new
end

if __FILE__ == $0
  item_code = ItemCode.new("./item.txt")
  recs = []
  item = Item.new(item_code)
  i_year = ARGV[0].to_i if ARGV[0] != nil # ARGV[0]:年度
  if ARGV[1] != nil                       # ARGV[1]:データファイル
    data_file = ARGV[1]
    if ARGV[2] != nil                     # ARGV[2]:期末残高
      start_money = ARGV[2].to_i    
    end
  else
    data_file = "./accounts.dat"
  end
  File.open(data_file) do |f|
    f.each do |line|
      recs.push(line.chomp)
    end
  end
  rec = Record.new
  bef = ""
  while true
    print "> "
    s_in = STDIN.gets.chomp
    s_in = bef if s_in =~ /^$/
    case
    when s_in =~ /^(all print|all|a)$/
      display_recs(recs, start_money)
    when s_in =~ /^(print|p)$/
      display_rec(rec, item_code)
    when s_in =~ /^(quit|q)$/
      break
    when s_in =~ /^(help|h)$/
      message("all print|all|a|print|p|quit|q|help|h|ok|add") 
      item.out
    when s_in =~ /^(help \d+|h \d+)$/
      message("all print|all|a|print|p|quit|q|help|h|ok|add") 
      item.lookup(s_in.sub(/^h\S*\s+/, ""))
    when s_in =~ /^(ok|add)$/
      if rec.ok?
        ok(recs, rec)
      else
        message("ERROR")
      end
    else
      if ! rec.add(item_code, s_in, i_year)
        message("ERROR")
      end
    end
    bef = s_in
  end
  display_recs(recs, start_money)
  File.open(data_file, "w") do |f|
    recs.each do |line|
      f.puts(line)
    end
  end
  exit(0)
end

