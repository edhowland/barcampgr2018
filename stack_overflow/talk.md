##### Speaker's Important message:

In my talk on Saturday, Aug. 25th, 2018, I was less than clear
about using the CPS method identified herein to prevent stack overflows.

If your language implementation does not support tail call optimization,
then just rewriting your recursive functions to use Continuation Passing Style
(CPS), will not save you.

However, you can use a form of this with another technique, called 'Trampolining'.

This document corrects this mistake and shows one form of implementing a trampoline to use along with a continuation.


# How to avoid Stack Overflow

## What causes a stack overflow?

Sometimes, we might get an exception in our code alongs the lines of:

Error: Maximum stack limit exceeded.

### Possible reasons for stack overflow errors

- Badly written recursive functions.
- Runaway mutually recursive errors.
- Exceedly deep nested data structures.
- Malformed input data, especially from over the wire sources.

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



## Approach #2: Continuation Passing Style: CPS


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

### The identity function

In the above recipe and in the code below, we have mentioned
the need for an initial identity function. This is simply a lambda that
returns its own parameter without performing additional computation.

```
;;; The identity lambda
(lambda (x) x)
```


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


## What to do if your favorite language does not support TCO

There is an additional technique called the trampoline method that you might be able to use.
It is similar to the continuation passing scheme, CPS, but uses another type of driver function.

In this technique, you create a function with an infinite loop that will break out
under the passed in function returning a non-function. I know this sounds crazy, but it is really quite simple.

First, let's review our TCO stuff in the language like Ruby which has optional TCO.

First, our direct style factorial:

```

#!/usr/bin/env ruby
# fact-dir.rb - Factorial Direct style

def fact n
  if n.zero?
    1
  else
    n * fact(n - 1)
  end
end
```


Now, our CPS version

```
#!/usr/bin/env ruby
# fact-cps - Factorial Continuation Passing Style: CPS

def fact n, k=->(v) {v}
  if n.zero?
    k.call(1)
  else
    fact(n - 1, ->(v) { k.call(n * v) })
  end
end
```


This works, but still suffers from possible stack overflows with large values of 'n'.

Let's add in Tail Call Optimization:

```
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
```


## Jump on the trampoline!

Here is our new fact method with 2 driver methods.

1. The fact(n) method  sets up the call to the trampo(k) method.
2. The trampo(k) keeps driving its 'k'  function until it no longer returns another function.

```
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

```


Note that we have returned to using a modified version of the APS style
of fact, here called fact_jmp. It takes a number and a an accumulator.
But instead of calling itself recursively, it returns a thunk.

### What the frak is a 'thunk'?

Very simply, it is just an anonymous lambda function that takes no parameters.
The effect of returning a thunk is to delay the computation until it is needed.

You might see these used in some lazy iterators, or other things.

The fact driver method itself wraps a call to the initial fact_jmp method in the first thunk.
Then it calls the trampo method with this thunk.

The trampo method enters a loop continuing to call the thunk
until the return from the thunk call is no longer another thunk.

In the fact_jmp method, where we would usually have a call to the the recursive
method, we just return a new thunk that  wraps the remaing work to do. IOW: a Continuation!





## Which languages support TCO?

Most, if not all, functional languages support it out of the box.

- Ruby: Not by default, but can be set on by some envronment setting.
- Javascript - Yes, in ES6, but not before that. Not sure if Bable will help you there. (See the Babel TCO plug-in link below)
- Perl - It appears so. Needs more research, and also Perl5? or Perl6?
- Python - See the link below.
- Lua - Yes, appparently
JVM languages: Java, Clojure, etc. - No.
- ClojureScript - Yes, if using ES6, or the Babel plug-in
- Scala - Although a JVM language, the compiler rewrites recursion calls into iterative loops.
- .Net languages: F# : Yes, C#: No. Not sure about others.

## Caveats regarding using TCO

When relying on tail code to be optimized away, you will not get stack traces
when you are trying to debug your code. Perhaps you can use some
optional flags for either development or production mode. Be sure to
turn on TCO, if possible, if using any type of CI testing.


## Conclusion

We have seen some ways to avoid potential stack overflows in our code.
Many of these methods rely on the ability of the various language runtimes
to support a low-level tachnique called tail call optimization or elimination.

We have seen some ways to rewrite our code to take advantage TCO if it exists.

1. Accumulator Passing Style: APS
2. Continuation Passing Style: CPS

Both of the above methods rely on adding an additonal parameter
to our function signature, and either adding a driver function or using
a default parameter value.

We also saw a method to use in the case our language does now support TCO.

3. The trampoline method.

In summary, although using these techniques to rewrite your recursive functions
may seem like a bother, in my humble opinion, they do not suffer too much
from writing a direct style function.

If you are writing library code that someone else is going to rely on, it
should be your responsiblity to ensure you do not introduce  unexpected behaviour
whenever your users of your library code deploy to production.

I hope these techniques help you deal with the nasty stack overflow errors.

For further reading, check out the links below.


## Links

[Which languages support tail call optimization?](https://www.quora.com/Which-programming-languages-support-tail-recursion-optimization-out-of-the-box)

The above link discusses the  problem nicely. It states that most, if not all, functional languages
support tail  call elimination/optimization. Exceptions are: Clojure and other
laanguages based on the JVM. 

[Does Python support TCO?])https://chrispenner.ca/posts/python-tail-recursion(

Apparently not. The author does provide a way to do it in this article.

[Tail calls in Ruby])http://nithinbekal.com/posts/ruby-tco/)

The author also provides a bit on using memoization for factorial as well.
He also mentions why Guido does not want to support it in C Python.,
while Matz can go either way.

[Does Scala support tail call optimization?](https://stackoverflow.com/questions/1677419/does-scala-support-tail-recursion-optimization)

Apparently, it rewrites the recursive methods at compile time.

[Bable plug-in for TCO](https://www.npmjs.com/package/babel-plugin-tailcall-optimization(





This plug-in also rewrites functions into iterative loops at compile time.
