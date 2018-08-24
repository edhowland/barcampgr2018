[slide_10](slide_10.md)

### Problems with continuations

[An arguement against call/cc](http://okmij.org/ftp/continuations/against-callcc.html)

- Memory leaks
- Hard to implement generators, thread control and lazy streams


### A simple implementation

In Vish, we implement the callcc function like this:
```

defn callcc(l) {
  l(_mkcontinuation(unwind_one(__frames()), :callcc))
}
```

