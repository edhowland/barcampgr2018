[slide_9](slide_9.md)

### Delimited Continuations

We would like to be able to compose our continuations in a larger expression.
With unlimited continuations, this is much harder, requiring more plumbing.
It would be nice if we could bound our continuation at some previous step

Imagine our sandwich metaphor. What if we could turn our sandwich  into a Panini?

```
# Our new RPN example from before.
100
5
3
4
*
+
*

# => 1700
# Delimited:

1000
..........
5
----------
3
4
*
----------
+
..........
*
```

In the above example, our delimited continuation captures the computation
between the dotted line and the dashed line, and then the dashed line and the dotted line.








