# -*- coding:utf-8 -*-
#
# item.rb
#

$CODE = 0
$COMMENT = 1

class ItemCode
  attr_accessor :items
  def initialize(file="item.txt")
    @items = Hash.new
    File.open(file) do |f|
      f.each do |l|
        line = l.chomp.to_s
        if line !~ /^\s*#/ && line !~ /^\s*$/ # コメント行、空白行スキップ
          fields = line.split(/,/)
          @items[fields[$CODE].to_s] = fields[$COMMENT].to_s
        end
      end
    end
  end

  def check(code)
    @items[code.to_s]
  end
end

if __FILE__ == $0
  begin
    item_code = ItemCode.new
    print "> "
    s_in = gets.chomp
    unless item_code.check(s_in)
      puts "ないよ"
    end
  rescue => eval
    puts "めんご:#{eval}"
    puts eval.class
    puts eval.message
    puts eval.backtrace
  end
end
