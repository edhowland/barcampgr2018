#!/usr/bin/env ruby
# stack_limit.rb - estimate the max stack depth

def eternal &blk
  yield 1
  eternal(&blk)
end

limit = 0
begin
  eternal {|x| limit += x }
rescue SystemStackError => e
  puts 'In SystemStackError'
  puts 'the maximum depth is:'
    puts "#{e.backtrace.length}"

rescue => err
  puts "some other error occured: #{err.class.name}"
end


puts "limit: #{limit}"
