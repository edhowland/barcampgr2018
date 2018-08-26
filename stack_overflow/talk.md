
# How to avoid Stack Overflow

## What causes a stack overflow?

Sometimes, we might get an exception in our code alongs the lines of:

Error: Maximum stack limit exceeded.

### Possible reasons for stack overflow errors

- Badly written recursive functions.
- Runaway mutually recursive errors.
- Exceedly deep nested data structures.

... and other causes.

## The function call stack

A call stack acts like a memory of what has happened up to this point.

E.g. function A calls function B which calls function C and so on.
The stack is divided into frames that record state of parameters, local variables and the return program counter.
After each function returns, it return value is pushed on thedata stack for the previous
stack frame. (Note: See data stacks)
The porgram counter is set to the return code pointer and the stackframe is popped
off the top of the stack. In this way, the stack grows and shrinks as function
calls are made and returned. This also applies to library calls.

Note: Some library  calls end up calling into the OS and are called system calls.
These calls do not use the program stack allocated for the current process. They
might use some other  memory data structure in kernel space.

### How deep is my stack?

A good question. The answer is: It varies.

Each language compiler and runtime environment might choose different 
allocation strategies. Most interpreted languages in use today probably
rely on the C language stack. E.g. Ruby, Javascript and C Python.

### Estimating your own stack limit.

Here is a simple Ruby script to get the maximum stack depth.


