
# How to avoid Stack Overflow

## What causes a stack overflow?

Sometimes, we might get an exception in our code alongs the lines of:

Error: Maximum stack limit exceeded.

### Possible reasons for stack overflow errors

- Badly written recursive functions.
- Runaway mutually recursive errors.
- Exceedly deep nested data structures.

... and other causes.

## The function call stack

A call stack acts like a memory of what has happened up to this point.

E.g. function A calls function B which calls function C and so on.
The stack is divided into frames that record state of parameters, local variables and the return program counter.
After each function returns, it return value is pushed on thedata stack for the previous
stack frame. (Note: See data stacks)
The porgram counter is set to the return code pointer and the stackframe is popped
off the top of the stack. In this way, the stack grows and shrinks as function
calls are made and returned. This also applies to library calls.

Note: Some library  calls end up calling into the OS and are called system calls.
These calls do not use the program stack allocated for the current process. They
might use some other  memory data structure in kernel space.

### How deep is my stack?

A good question. The answer is: It varies.

Each language compiler and runtime environment might choose different 
allocation strategies. Most interpreted languages in use today probably
rely on the C language stack. E.g. Ruby, Javascript and C Python.

### Estimating your own stack limit.

Here is a simple Ruby script to get the maximum stack depth.

```
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

```



Running this on my MacBook Air:

```

. ruby -v
ruby 2.4.1p111 (2017-03-22 revision 58053) [x86_64-darwin14]
. ruby stack_limit.rb 
In SystemStackError
the maximum depth is:
11914
limit: 11912
```

So, it seems that my maximum limit is around 11K. I can get a bit more by dropping the 
parameter: blk.

As far as I know, Javascript might be around 20K.

Whatever, these are hard limits. In our data intensive world, one can imagine
running up against these borders.


## Approaches to avoiding reaching stack limits

You can always rewrite recursive functions in imperative fashion using loop
iterations instead. This may get ugly. Here, I am going to avoid any examples to
spare you horror of having to read them.

### Tail position

If your language supports tail call optimization, you can rewrite your recursive code to
take advantage of that.

The general approach is to make sure to place the the recursive function call in
the final slot of your function body; the "tail" position.
Language runtimes that utilize tail call optimization will reuse the existing
stack frame and just perform essentially a jump instruction back to top of
the function body.

Let's see some code:

This example is written in Scheme, likely to be the first language to employ tail call optimization.

```
;; Factorial naive style
(define (fact n)
  (if (zero? n) 1
    (fact (sub1 n))))
```



