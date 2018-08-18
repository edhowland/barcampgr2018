# Deep Dive into Continuations and CPS

## What are continuations?

## What is Continuation passing style?

## Continuations via call-with-current-continuation or call/cc

A continuation is simply: the remainder of the work left to be done.

### The sandwich joke

Say you want to make a sandwich. 
1. You go to the fridge
2. Pull 2 slices of bread
3. grab the meat, cheese and any veggies.
4. Get the condiments
5. Assemble the ingrediants
6. Place between the 2 bread slices.
7. Invoke the continuation.
1. Go to the fridge (... all your sandwich fixins have disappeared in a puff of smoke :(




### First class continuations via call/cc or callcc.

One line example.

This code is in Ruby, but the language does not matter.

```
$ irb -W0 -r continuation
>> "Hello #{callcc {|k| $k = k; 'World'}}"
=> "Hello World"
>> 
?> $k
=> #<Continuation:0x007f846e916488>
>> $k.call('Sailor')
=> "Hello Sailor"
>> $k.call('George')
=> "Hello George"
>> $k.call('Gracie')
=> "Hello Gracie"
>> x=$k.call('yourself')
=> "Hello yourself"
>> x
=> nil
```

But we can get the effect we want:

```

>> x = "Hello #{callcc {|k| $k=k; 'World'}}"
=> "Hello World"
>> $k.call('yourself')
=> "Hello yourself"
>> x
=> "Hello yourself"

````


#### First caveat

We cannot use the result of invoking the continuation in further expressions
as illustrated by the first example of "x = $k.call('yourself')"

The reason is these are called Unlimited Continuations. What we need for this
functionality is Delimited Continuations. More on that later.

#### Second caveat: Do NOT type this code into a Ruby file and try to run it.

Why not? Can you guess?


### How does this work?

Let's say you have this canonical expression:

```
# Ruby:

>> 5 + 3 * 4
=> 17

;; Scheme version

> (+ 5 (* 3 4))
17

```

With a continuation:

```
# Ruby

>> 5 + callcc {|k| 3 * 4}
=> 17

;; Scheme:


> (+ 5 (call/cc (lambda (k) (* 3 4))))
17

```

Let's save the continuation in $k:
```
# Ruby:

>> 5 + callcc {|k| $k=k; 3 * 4}
=> 17
>> $k.call(10)
=> 15
>> $k.call(7 - 2)
=> 10
>> 

;;; Scheme:

> (define $k '())
> (+ 5 (call/cc (lambda (k) (set! $k k) (* 3 4))))
17
> $k
#<continuation>
> ($k 10)
15
> ($k (- 7 2))
10

```


### The RPN version

Let's translate the above into postfix notation: (I.e. Reverse Polish Notation:
RPN or H.P. calculator style)
``
5
3
4
*
+

=> 17
```


With a continuation graphically:

```
5
----------
3
4
*
----------
+

=> 17
```


The continuation is everything above and below the dashed lines:

This is what the 'k' continuation captures:

```
5
_
+
```

The '_' above is the hole  into which we will plug the the parameter we pass to
the call to 'k.call( _ )'





### Actual use case: Exceptions

We can apply continuations to the case of implementing an exception handler.

Here is an example of a simple handler for a safe_fread function in Vish:

```
# safe_fread.vs - safe version of fread using continuations for exceptions
defn safe_fread(fname) {
  # guard exception handlers
  nofile=except("No such file: %{:fname}")
    noread=except("Cannot read file: %{:fname}")
  result=callcc(->(k) {
    fexist?(:fname) || k(nofile(callcc(->(cc) {:cc})))
    freadable?(:fname) || k(noread(callcc(->(cc) {:cc})))
    fread(:fname)
  })
  :result
}
```


### Delimited Continuations

We would like to be able to compose our continuations in a larger expression.
With unlimited continuations, this is much harder, requiring more plumbing.
It would be nice if we could bound our continuation at some previous step

Imagine our sandwich metaphor. What if we could turn our sandwich  into a Panini?

```
# Our new RPN example from before.
100
5
3
4
*
+
*

# => 1700
# Delimited:

1000
..........
5
----------
3
4
*
----------
+
..........
*
```

In the above example, our delimited continuation captures the computation
between the dotted line and the dashed line, and then the dashed line and the dotted line.






### One Shot continuations

Usually called with 'call/1cc'.



### Problems with continuations

[An arguement against call/cc](http://okmij.org/ftp/continuations/against-callcc.html)

- Memory leaks
- Hard to implement generators, thread control and lazy streams


### A simple implementation

In Vish, we implement the callcc function like this:
```

defn callcc(l) {
  l(_mkcontinuation(unwind_one(__frames()), :callcc))
}
```
## Continuation Passing style 99 

### Fibonacci example

;; CPS ver of fib

(define (fib-cps n k)
  (cond
    [(zero? n) (k 0 1)]
    [(= n 1) (k 0 1)]
    [else (fib-cps (sub1 n) (lambda (x y)
                                (k y (+ x y))))]
  )
)

(define (fib m) (fib-cps m (lambda (x y) (+ x y))))
```


