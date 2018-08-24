[slide_7](slides/slide_7.md)


### The RPN version

Let's translate the above into postfix notation: (I.e. Reverse Polish Notation:
RPN or H.P. calculator style)
```
5
3
4
*
+

=> 17
```


With a continuation graphically:

```
5
----------
3
4
*
----------
+

=> 17
```


The continuation is everything above and below the dashed lines:

This is what the 'k' continuation captures:

```
5
_
+
```

The '_' above is the hole  into which we will plug the the parameter we pass to
the call to 'k.call( _ )'



