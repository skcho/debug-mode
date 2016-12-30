debug-mode
==========

*Observe intermediate states easily.*

What is this
------------

This is a simple library to make an interactive debug mode for OCaml
programs.

### Workflow

1.  Design *debug options*.

    Follow [TUTORIAL.md](TUTORIAL.md) for more details on how to
    design the debug options.

2.  Invoke `Debugmode.run` in your program.  Then, the program will
stop and a simple debugging shell will start on the command line.

3.  Observe an intermediate state of the program by selecting debug
options you designed.

*REMARK: Its only goal is to make it easy to observe intermediate
 states, so it does not support GDB-style features such as "time
 travel" and "call stack print".*

How to use
----------

Simply,

1. Copy `debugmode.ml` and `debugmode.mli` to your source directory.
2. Compile them together with your OCaml code.

License
-------

This is free and unencumbered software released into the public
domain.  For more information, see
[http://unlicense.org/](http://unlicense.org/) or [LICENSE](LICENSE).
