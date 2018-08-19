( define ( pyth x y ) ( sqrt ( + ( * x x ) ( * y y ))))

Direct style
Continuation passing style
(define (pyth x y)
 (sqrt (+ (* x x) (* y y))))
(define (pyth& x y k)
 (*& x x (lambda (x2)
          (*& y y (lambda (y2)
                   (+& x2 y2 (lambda (x2py2)
                              (sqrt& x2py2 k)))q

)))))
(define (fa