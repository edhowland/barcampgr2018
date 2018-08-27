
;; fact-cps - Continuation passing style
(define (fact-cps n k)
  (if (zero? n) (k 1)
  (fact-cps (sub1 n) (lambda (v) (k (* v n))))))



(define (fact n)
  (fact-cps n (lambda (x) x)))
