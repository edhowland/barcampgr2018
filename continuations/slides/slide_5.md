[slide_6](slide_6.md)

## Ruby canonical example

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

