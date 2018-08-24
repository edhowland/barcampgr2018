[slide_16](slide_16.md)

### Slip in our call/cc in this chain:
```
# create our call/cc fn
defn callcc(l, k) { l(:k) }
defn f(n, k) { k(100 * :n) }
defn g(n, k) { k(5 + :n) }
defn h(x, y, k) { k(:x * :y) }

# Also, create our identity function for testing and to get the ball rolling
defn id(x) { :x }

# set up our top-level variable
kk=9
# Now use callcc in our expression
defn chain4(x, y) {
  callcc(->(k) {
  kk=:k
  h(:x, :y, :k) }, ->(v) {
  g(:v, ->(x2) {
  f(:x2, :id)
  })})
}
```


