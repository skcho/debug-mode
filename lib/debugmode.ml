(* Debugmode *)

module Cmd = struct

  type t =
    | CNum of int
    | CStr of string
    | CUp of int

  let compare = compare

  let of_string s =
    if Str.string_match (Str.regexp "^\\^+$") s 0 then
      CUp (String.length s)
    else
      match int_of_string s with
      | n -> CNum n
      | exception _ -> CStr s

  let string_of = function
    | CNum i -> string_of_int i
    | CStr s -> s
    | CUp n -> String.make n '^'

  let prerr x = prerr_string (string_of x)

end

module Query = struct

  module Children = struct

    include Map.Make (Cmd)

    let add e v cs =
      if mem e cs then
        prerr_endline ( "WARNING: duplicated " ^ Cmd.string_of e
                        ^ " is added as a command." );
      add e v cs
  end

  type t =
    | Leaf of (unit -> unit)
    | Node of children_t

  and children_t =
    { children : child_t Children.t
    ; i : int }

  and child_t =
    { name : string
    ; gen_q : string list -> t }

  let empty = {children = Children.empty; i = 0}

  let find_shortcut s =
    let id = "[a-zA-Z][a-zA-Z0-9!@#\\$%&\\*()-=_\\+{}|;:,\\.<>/\\?`~]*" in
    match Str.search_forward (Str.regexp ("\\[\\(" ^ id ^ "\\)\\]")) s 0 with
    | _ ->
      let scut = Str.matched_group 1 s in
      let s' =
        Str.replace_first (Str.regexp ("\\(\\[" ^ id ^ "\\]\\)")) scut s
      in
      Some (scut, s')
    | exception _ -> None

  let add n f cs =
    let (cmd, n', i') =
      match find_shortcut n with
      | Some (scut, n') -> (Cmd.CStr scut, n', cs.i)
      | None -> (Cmd.CNum cs.i, n, cs.i + 1) in
    { children = Children.add cmd {name = n'; gen_q = f} cs.children
    ; i = i' }

  let find_child cmd cs =
    match Children.find cmd cs.children with
    | q -> Some q
    | exception _ -> None

  let prerr_child k child_q =
    prerr_string "  ";
    Cmd.prerr k;
    prerr_string " : ";
    prerr_endline child_q.name

  let prerr_children cs = Children.iter prerr_child cs

  let prerr_endline = function
    | Leaf c ->
      ( match Printexc.print c () with
        | () -> ()
        | exception _ -> () )
    | Node cs -> prerr_children cs.children

end

module Stack = struct

  type stack_t = (Query.t * string) list

  let empty = []

  let rec prerr = function
    | [] -> ()
    | (_, n) :: tl ->
      prerr tl;
      prerr_string " > ";
      prerr_string n

  let prerr_endline s =
    if List.length s = 0 then prerr_endline "STACK empty" else
      ( prerr_string "STACK";
        prerr s;
        prerr_newline () )

end

module Run = struct

  let prerr_invalid_cmd () = prerr_endline "ERROR: Invalid command"

  let get_cmd_args s =
    match Str.split (Str.regexp "[ \t]+") s with
    | [] -> None
    | c :: args -> Some (Cmd.of_string c, args)

  let rec process s q =
    prerr_newline ();
    Stack.prerr_endline s;
    Query.prerr_endline q;
    prerr_newline ();
    process_cmd s q

  and process_cmd s q =
    prerr_string "$ ";
    flush stderr;
    match q, read_line () |> get_cmd_args with
    | Query.Node qs, Some (Cmd.CNum _ as cmd, args)
    | Query.Node qs, Some (Cmd.CStr _ as cmd, args) ->
      ( match Query.find_child cmd qs with
        | Some c -> run_child s q c args
        | None -> (prerr_invalid_cmd (); process_cmd s q) )
    | _, Some (Cmd.CUp n, _) -> process_up n s
    | _, None -> process_cmd s q
    | _, _ -> (prerr_invalid_cmd (); process_cmd s q)

  and process_up n s =
    match s with
    | (q, _) :: tl when n <= 1 -> process tl q
    | _ :: tl -> process_up (n - 1) tl
    | _ -> ()

  and run_child s q c args =
    match Printexc.print c.Query.gen_q args with
    | q' -> process ((q, c.Query.name) :: s) q'
    | exception _ -> process_cmd s q

  let run q =
    prerr_endline "Hello debug mode.";
    prerr_endline "Try '^' to pop the STACK.";
    process Stack.empty q;
    prerr_endline "Bye debug mode!"

end

type t = Query.t

let short s = Query.Leaf (fun () -> prerr_endline s)

let long l = Query.Leaf l

type children_t = Query.children_t

let empty = Query.empty

let add = Query.add

let node cs = Query.Node cs

let run = Run.run
