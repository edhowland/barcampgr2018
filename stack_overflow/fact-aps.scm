;; Accumulator passing style : APS
(define (fact-aps n acc)
  (if (zero? n) acc
  (fact-aps (sub1 n) (* n acc))))
(define (fact n)
  (fact-aps n 1))
