#!/usr/bin/env ruby
# fib.rb - Direct version of Fibonacci alg.

def fib n
  if n.zero?
    1
  elsif n == 1
    1
  else
    fib(n - 2) + fib(n - 1)
  end
end
