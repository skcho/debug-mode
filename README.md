debug-mode
==========

Interactive CLI debug mode library for OCaml

Problems
--------

* Debugging by excessive log functions: Sometimes the data to watch
  is too big to apply *log-and-grep* approach.

* Debugging by adding small number of print functions: The adding
  print functions is, in many cases, *not complete* because of various
  input data and execution status.

* Debugging by using debugging tools such as
  [ocamldebug](http://caml.inria.fr/pub/docs/manual-ocaml/debugger.html):
  Well, it may work.  I don't know.

  One problem I can think is how to traverse OCaml's complicated, or
  user-defined, structures such as map, set, or graph using the tools.
  This is not an issue if a language has a huge standard library.  For
  example, in C# or Java, debugging tools already know how to traverse
  pre-defined structures in standard libraries and users hardly define
  their own data structures.  However, OCaml's standard library is
  minimal, so users use various external libraries or define their own
  data structures, which makes it hard for debugging tools to prepare
  some traversal functions for the complicated data
  structures---though I like the minimal standard library policy.

Tutorial
--------

The debug-mode library provides,

* an interactive debugging shell, in which
* data structures are traversed through some traversal functions you
  define.

See [TUTORIAL.md](TUTORIAL.md).

REMARK: It is designed to traverse complicated data, not to replace
other debugging tools.  It *does not* provide,

* time travel, e.g., `run`, `next [count]`, and `previous [count]` in
  [ocamldebug](http://caml.inria.fr/pub/docs/manual-ocaml/debugger.html),
* watching call stacks
* etc.

Build
-------

```
$ ./configure
$ make
$ make install
```

### Documentation

```
$ make doc
```

### Example

```
$ make example.native
$ ./example.native
```

### Uninstall

```
$ make uninstall
```

License
-------

This is free and unencumbered software released into the public
domain.  For more information, see
[http://unlicense.org/](http://unlicense.org/) or [LICENSE](LICENSE).
