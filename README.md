debug-mode
==========

Interactive CLI debug mode library for OCaml

What is this for?
-----------------

* Traverse data: it helps in constructing a debugging program that
  traverses internal data of your program, which is sometimes too big
  to "print and grep", or too complicated to "set a breakpoint and
  watch a low-level program state".

* Interactive debugging: when the debug mode starts, it stops the
  world and runs a debug shell that helps you to watch only data you
  are insterested in.  What you have to do is to define major things,
  for example,

  1. what data to print,
  2. how to print the data.

  The other minor and annoying things, which are usually related to
  the interaction, will be done by the library, e.g., processing
  command strings from users.

Tutorial
--------

[TUTORIAL.md](TUTORIAL.md)

Install
-------

TODO

License
-------

This is free and unencumbered software released into the public
domain.  For more information, see
[http://unlicense.org/](http://unlicense.org/) or [LICENSE](LICENSE).
