;; Accumulator passing style : APS
(define (fact-aps n acc)
  (if (zero? n) acc
  (fact-aps (sub1 n) (* n acc))))
(define (fact n)
  (fact-aps n 1))

```

;; fact-cps - Continuation passing style
(define (fact-cps n k)
  (if (zero? n) (k 1)
  (fact-cps (sub1 n) (lambda (v) (* n (k v))))))



(define (fact n)
  (fact-cps n (lambda (x) x)))
