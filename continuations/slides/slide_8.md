[slide_8](slides/slide_8.md)


### Actual use case: Exceptions

We can apply continuations to the case of implementing an exception handler.

Here is an example of a simple handler for a safe_fread function in Vish:

```
# safe_fread.vs - safe version of fread using continuations for exceptions
defn safe_fread(fname) {
  # guard exception handlers
  nofile=except("No such file: %{:fname}")
    noread=except("Cannot read file: %{:fname}")
  result=callcc(->(k) {
    fexist?(:fname) || k(nofile(callcc(->(cc) {:cc})))
    freadable?(:fname) || k(noread(callcc(->(cc) {:cc})))
    fread(:fname)
  })
  :result
}
```


