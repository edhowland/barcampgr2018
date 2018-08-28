#!/usr/bin/env ruby
# fib-memo.rb - Memoized  version of Fibonacci alg.

def fib n, acc={}
  if acc[n]
    return acc[n]
  end
  if n.zero?
    1
  elsif n == 1
    1
  else
    acc[n] = fib(n - 2, acc) + fib(n - 1, acc)
  end
end
