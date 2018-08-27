
#!/usr/bin/env ruby
# fact-dir.rb - Factorial Direct style

def fact n
  if n.zero?
    1
  else
    n * fact(n - 1)
  end
end
