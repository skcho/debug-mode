Tutorial
========

We explain how to use the library in a gradual order from easy cases
to complicated ones.

NOTE: for simplicity, we use a module alias of the `Debugmode` module.

```ocaml
module DM = Debugmode
```

String query
------------

*Query* is the unit to traverse in the debug mode.  We will see
several kinds of queries in the tutorial.

Suppose the data we want to traverse is simply a string.

```ocaml
let name = "Alice"

let query = DM.short name
let _ = DM.run query
```

A string query is defined by `DM.short`.  Then, it runs the query by
applying `DM.run`.  Let's see what happens when running the above
code.

```
STACK empty
Alice

$
```

* `STACK` represents queries that have traversed up to now.  It is a
  similar notion to directory, i.e., the empty `STACK`
  corresponds to the root directory `/`.

* `Alice` is the string data we wanted.

* `$` is a prompt of the debug shell.  We input some commands here,
  but for now the exit command is the only command available because
  we have not defined any commands yet.

This example is not that interesting.  Let's exit by entering `^`.

Option query
------------

Let's see more complicated cases.  Suppose we want to traverse
multiple data.

```ocaml
type t =
  { name : string
  ; hobby : string }

let gen_query d =
  DM.empty
  |> DM.add "name" (fun _ -> DM.short d.name)
  |> DM.add "hobby" (fun _ -> DM.short d.hobby)
  |> DM.node

let data =
  { name = "Alice"
  ; hobby = "programming" }

let _ = DM.run (gen_query data)
```

Let's see what happens when running the code, first.

```
STACK empty
  0 : name
  1 : hobby

$
```

It prints two available options the names of which are `name` and `hobby`
and commands to select one of them are
`0` and `1`, respectively.  Let's enter the command `1`.

```
STACK > hobby
programming
```

It prints `programming` with the pushed stack, `STACK > hobby`.
What's going on here?

```ocaml
let gen_query d =
  DM.empty
  |> DM.add "name" (fun _ -> DM.short d.name)
  |> DM.add "hobby" (fun _ -> DM.short d.hobby)
  |> DM.final
```

We defined a function, `gen_query`, that generates a query that
contains options to traverse.

* `DM.empty` is the empty set of options.

* `DM.add n f` adds an option with a name, `n`, and a function, `f`,
  that generates the next query to traverse.  For example,

  ```ocaml
  DM.add "hobby" (fun _ -> DM.short d.hobby)
  ```

  adds an option with the name `"hobby"`, and if the option is
  selected, `DM.short d.hobby` is traversed as the next query.

* `DM.final` finalizes the set of options and makes a query.

To conclude, we added two options to print each fields of the record
and `DM.run` started an interactive shell for us to select one of the
options.

If we enter `^`, it pops the `STACK`, so it goes back to the previous
state, before entering the `1` command.  One more `^` exits the debug
mode.

### TIP: string command

Basically, commands are natural numbers assigned from zero
automatically.  On the other hand, we can specify string commands
using the parentheses, `[` and `]`, in option names, as following.

```ocaml
let gen_query d =
  DM.empty
  |> DM.add "[n]ame" (fun _ -> DM.short d.name)
  |> DM.add "[h]obby" (fun _ -> DM.short d.hobby)
  |> DM.final
```

```
STACK empty
  h : hobby
  n : name
```

### TIP: quick exit

The special command, `^`, can be used to pop multiple queries from the
`STACK`.  For example, `^^` pops two times and `^^^` pops three times.
Therefore, if we enter long enough `^`s, the debug mode exits
immediately.

Long string query
-----------------

Sometimes we may want to print a multi-lined very long data, however
it is not a good idea to use `DM.short` for that, because it requires
to compose a long string value, which is inefficient in many cases.
Use `DM.long` instead, the argument of which is a function that prints
the long data by itselt.

```ocaml
let print_long_msg () =
  prerr_endline "This is very long message.";
  prerr_endline "Isn't it? :P"

let query = DM.long print_long_msg
let _ = DM.run query
```

The result is as follows.

```
STACK empty
This is very long message.
Isn't it? :P
```

### TIP: side effect

We can use the function query to raise some side effects such as
writing a file.

Option query with arguments
---------------------------

```ocaml
DM.add "[n]ame" (fun _ -> DM.short d.name)
```

Do you remember that the second argument of `DM.add` is a function?
Actually, the function gets a string list of additional words
following the command.  For example, if an option is add by,

```ocaml
DM.add "[n]ame" gen_query_f
```

and some arguments are given with the `n` command as follows,

```
$ n arg1 arg2
```

it generates the next query by running `gen_query_f ["arg1"; "arg2"]`.
