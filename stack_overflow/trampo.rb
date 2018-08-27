#!/usr/bin/env ruby
# trampo.rb - Trampoline method of invoking recursive where you do not TCO enabled

def trampo k
  while true  do
    k = k.call
    return k if !k.respond_to?(:call)
  end

end

def fact_jmp n, acc
  if n.zero?
    acc
  else
    ->() { fact_jmp(n - 1, n * acc) }
  end
end

# New and improved driver function using the trampoline method
def fact(n)
  m = method(:fact_jmp)
  trampo(->() { m.call(n, 1) })
end
