[slide_1](slide_1.md)

### The 4 rules for CPS transformation

1. Pass each function an extra parameter - cont.
2. Whenever the function returns an expression that doesn't contain function calls, send that expression to the continuation cont instead.
3. Whenever a function call occurs in a tail position, call the function with the same continuation - cont.
4. Whenever a function call occurs in an operand (non-tail) position, instead perform this call in a new continuation 



## Links

[Tutorial Tuesday #1 - Dr. William Byrd : youtube.com](https://www.youtube.com/watch?v=2GfFlfToBCo&t=5344s)

The original inspiration for this talk. Covers TCO, first class continuations and CPS.



[Section 3.3 Continuations and 3.4 Continuation Passing Style in Dr. Kent Dybig's book](https://scheme.com/tspl4/further.html#./further:h4)
[Chapter 5: Control structures](https://scheme.com/tspl4/control.html#g104)
[Continuation Passing Style: Wikipedia](https://en.wikipedia.org/wiki/Continuation-passing_style)
[Article on CPS in JavaScript](http://matt.might.net/articles/by-example-continuation-passing-style/)
[Advantages of CPS with examples in pattern matching: StackOverflow.com](https://stackoverflow.com/questions/8544127/why-continuation-passing-style)
[The 4 steps for CPS transformation](https://eli.thegreenplace.net/2017/on-recursion-continuations-and-trampolines/)




