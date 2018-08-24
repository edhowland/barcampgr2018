[slide_4](slide_4.md)
#### First caveat

We cannot use the result of invoking the continuation in further expressions
as illustrated by the first example of "x = $k.call('yourself')"

The reason is these are called Unlimited Continuations. What we need for this
functionality is Delimited Continuations. More on that later.

#### Second caveat: Do NOT type this code into a Ruby file and try to run it.

Why not? Can you guess?

1

