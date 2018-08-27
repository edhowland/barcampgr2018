#!/usr/bin/env ruby
# fact-cps-tco - Factorial Continuation Passing Style: CPS w/TCO turned on


RubyVM::InstructionSequence.compile_option = {
  tailcall_optimization: true,
    trace_instruction: false
    }
    
    

def fact n, k=->(v) {v}
  if n.zero?
    k.call(1)
  else
    fact(n - 1, ->(v) { k.call(n * v) })
  end
end

