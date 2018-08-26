#!/usr/bin/env ruby
# stack_limit.rb - estimate the max stack depth

def eternal
  eternal
end

begin
  eternal
rescue SystemStackError => e
  puts 'In SystemStackError'
  puts '__ the maximum depth is:'
    puts "__ #{e.backtrace.length}"

rescue => err
#  puts err.message
  puts "__ #{err.class.name}"
  puts '__ the maximum depth is:'
    puts "__ #{err.backtrace.length}"
    
end
