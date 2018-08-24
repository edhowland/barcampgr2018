[slide_15](slide_5.md)
### The CPS version

```
# First, create CPS-ified versions of direct sub-expressions functions
defn f(n, k) { k(100 * :n) }
defn g(n, k) { k(5 + :n) }
defn h(x, y, k) { k(:x * :y) }

# Also, create our identity function for testing and to get the ball rolling
defn id(x) { :x }

# Now our CPS-ified version
defn chain3(x, y) {
  h(:x, :y, ->(z) {
  g(:z, ->(x2) {
  f(:x2, :id)
  })})
}


```

