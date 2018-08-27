
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
    (* n (fact (sub1 n)))))

```

The problem above is that at every recursive call, we are leaving work on the table undone.
When we get to the base case where n is 0, we are left with a large nested set of unfinished expressions.

Consider the factorial of 5:

```
(fact 5)
;; results in:
(* 5 (* 4 (* 3 (* 2 (* 1 1)))))
```

Each call to * results in another stack frame pushed on the stack.

## Approach #1: Accumulator Passing Style: APS

Important Note: The following code will cause infinite loops if you supply the
the fact function with a negative number. It is left to the reader to see why for themself.

One way we can resolve this problem is to ensure that the call to our fact function
is in tail position, resulting in automatic tail call optimization.

The first step is to add an additional parameter to the the function signature.
This parameter will act as an accumulator.

Next, we create a wrapper function to initialize the whole ball rolling.

```
;; Accumulator passing style : APS
(define (fact-aps n acc)
  (if (zero? n) acc
  (fact-aps (sub1 n) (* n acc))))

;;; Our driver wrapper function: fact
(define (fact n)
  (fact-aps n 1))
```


Notice we have moved the (* n ..) calculation to the accumulator position.
This allows the (fact-aps ... ) call to be moved out to the tail position,
instead of the previous (* n (fact (sub1 n)) ... inner position.


In each call to fact-aps, the language runtime, Scheme in this case, will reuse the first
stack frame created in the fact driver function.
The effect of this move is to essentially change a recursive intensivefunction into a iterative one.



## Approach #2: Continuation Passing Style


Sometimes, it is not easy to use a single numeric value, or even a growing cons cell list
for an an accumulator. We might have to do additional work to compute our final answer.

Another technique is to provide a continuation function as the additional parameter
instead of an accumulator. A continuation is just the remaining work to be done.

The recipe to do this:

1.  Provide an additional parameter: 'k' that is the function to hold the continuation.
2. In the driver outer function, pass the identity function that will be the final step.
3. In the base case of the conditional, just call the continuation function 'k' with the final value.
4. In any recursive legs of the conditional, call the recursive function (now in the tail position)
5. For the 'k' parameter, create a new lambda function that performs the work and passes the result to the 'k' continuational passed in.


```

;; fact-cps - Continuation passing style
(define (fact-cps n k)
  (if (zero? n) (k 1)
  (fact-cps (sub1 n) (lambda (v) (k (* v n))))))

;;; Our driver function w/identity lambda as initial 'k' parameter

(define (fact n)
  (fact-cps n (lambda (x) x)))
```

In this way, we are threading the reamining work to be done by wrapping new lambdas around the call to the passed in previous lambda.
The inner most lambda is (usually) just the identity function, just returning
its own parameter.

The base case of the conditional is where we fire off the entire chain of lambda applications.


### The CPS version of fact:

The above code produces a nested set of anonymous lambda functions waiting to be called.
The important point to remember is that during the first rounds of the recursive calls,
we are storing the remaing work to do in these lambdas which are stored on the heap,
not on the stack. Our language runtime ensures that we have tail code optimization so only a single
stack frame will be created.

### But aren't you just delaying the enevatable?

You might have caught that once the base condition is reached, and we fire off the entire chain
of lambda applications, do not they all just cause more stack frames to be pushed?

Well, maybe. For this reason, we must also ensure that the call to the passed
in 'k' continuation function is also in the tail position to take advantage of TCO as well.







## Which languages support TCO?

Most, if not all, functional languages support it out of the box.

- Ruby: Not by default, but can be set on by some envronment setting.
- Javascript - Yes, in ES6, but not before that. Not sure if Bable will help you there.
- Perl - It appears so. Needs more research, and also Perl5? or Perl6?
- Python - See the link below.
- Lua - Yes, appparently
JVM languages: Java, Clojure, etc. - No.
- .Net languages: F# : Yes, C#: No. Not sure about others.



## Links

[Which languages support tail call optimization?](https://www.quora.com/Which-programming-languages-support-tail-recursion-optimization-out-of-the-box)

The above link discusses the  problem nicely. It states that most, if not all, functional languages
support tail  call elimination/optimization. Exceptions are: Clojure and other
laanguages based on the JVM. 

[Does Python support TCO?])https://chrispenner.ca/posts/python-tail-recursion(

Apparently not. The author does provide a way to do it in this article.

[Tail calls in Ruby])http://nithinbekal.com/posts/ruby-tco/)

The author also provides a bit on using memoization for factorial as well.

