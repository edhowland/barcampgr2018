#!/usr/bin/env ruby
# fact-cps - Factorial Continuation Passing Style: CPS

def fact n, k=->(v) {v}
  if n.zero?
    k.call(1)
  else
    fact(n - 1, ->(v) { k.call(n * v) })
  end
end

