[slide_4](slide_4.md)
## Bringing it all together

If we have performed a CPS transform on our code, then we get call/cc for free.

```
# First, Funkify the previous sub-expressions
defn f(n) { 100 * :n }
defn g(n) { 5 + :n }
defn h(x, y) { :x * :y }

# Now compose our full expression:
defn chain1(x, y) {
  f(g(h(:x, :y)))
}


# Next, let's unroll the call stack with a pipeline
defn chain2(x, y) {
  h(:x, :y) | g() | f()
}

```

