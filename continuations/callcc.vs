
defn callcc(l) {
  l(_mkcontinuation(unwind_one(__frames()), :callcc))
}
