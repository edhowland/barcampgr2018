(define (fib n)
  (cond
    [(zero? n) 1]
    [(eq? n 1) 1]
    [else (+ (fib (- n 2)) (fib (- n 1)))]
  )
)
