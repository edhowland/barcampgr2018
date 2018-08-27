#!/usr/bin/env ruby
# trampo.rb - Trampoline method of invoking recursive where you do not TCO enabled

def trampo k
  while true  do
    k = k.call
    return k if !k.respond_to?(:call)
  end

end

def fact_jmp n
  if n.zero?
    1
  else
    ->() { fact_jmp(n * 1) }
  end
end

def sub n
  if n.zero?
    0
  else
    ->() { sub(n - 1) }
  end
end
def countr n, acc
  if n.zero?
    acc
  else
    ->() { countr(n - 1, acc + 1) }
  end
end