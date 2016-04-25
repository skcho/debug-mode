(** Debugmode *)

module Cmd = struct

  type t =
    | CNum of int
    | CStr of string
    | CUp
    | CExit

  let compare = compare

  let make_from_str i s =
    match Str.search_forward (Str.regexp "\\[\\([a-zA-Z]+\\)\\]") s 0 with
    | _ -> (i, CStr (Str.matched_group 1 s))
    | exception _ -> (i + 1, CNum i)

  let make_from_cmd s =
    if s = "^" then CUp else
    if s = "^^" then CExit else
      match int_of_string s with
      | n -> CNum n
      | exception _ -> CStr s

  let get_cmd_args s =
    match Str.split (Str.regexp "[ \t]+") s with
    | [] -> None
    | c :: args -> Some (make_from_cmd c, args)

  let string_of = function
    | CNum i -> string_of_int i
    | CStr s -> s
    | CUp -> "^"
    | CExit -> "^^"

  let prerr x = prerr_string (string_of x)

end

module Query = struct

  module Children = Map.Make (Cmd)

  type t =
    | Short of string
    | Long of (unit -> unit)
    | Next of children_t

  and children_t =
    { children : child_t Children.t
    ; i : int }

  and child_t =
    { name : string
    ; gen_q : string list -> t
    }

  let empty = {children = Children.empty; i = 0}

  let add_child n f cs =
    let c = {name = n; gen_q = f} in
    let (i', cmd) = Cmd.make_from_str cs.i n in
    {children = Children.add cmd c cs.children; i = i'}

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
    | Short s -> prerr_endline s
    | Long l -> l ()
    | Next cs -> prerr_children cs.children

end

module State = struct

  type state_t = (Query.t * string) list

  let empty = []

  let rec prerr_rev = function
    | [] -> ()
    | (_, n) :: tl ->
      prerr_string " > ";
      prerr_string n;
      prerr_rev tl

  let prerr s = prerr_rev (List.rev s)

  let prerr_endline s =
    prerr_string "STATE";
    prerr s;
    prerr_newline ()

end

module Run = struct

  let prerr_invalid_cmd () = prerr_endline "ERROR: Invalid command"

  let rec process s q =
    State.prerr_endline s;
    Query.prerr_endline q;
    process_cmd s q

  and process_cmd s q =
    prerr_string "$ ";
    flush stderr;
    match q, read_line () |> Cmd.get_cmd_args with
    | Query.Next qs, Some (Cmd.CNum _ as cmd, args)
    | Query.Next qs, Some (Cmd.CStr _ as cmd, args) ->
      ( match Query.find_child cmd qs with
        | Some c -> process ((q, c.Query.name) :: s) (c.Query.gen_q args)
        | None -> (prerr_invalid_cmd (); process_cmd s q) )
    | _, Some (Cmd.CUp, _) ->
      ( match s with
        | (q, _) :: tl -> process tl q
        | _ -> () )
    | _, Some (Cmd.CExit, _) -> ()
    | _, None -> process_cmd s q
    | _, _ -> (prerr_invalid_cmd (); process_cmd s q)

  let run q =
    prerr_endline "Start debug mode.";
    process State.empty q;
    prerr_endline "Bye debug mode!"

end

type t = Query.t

let short s = Query.Short s

let long l = Query.Long l

let empty = Query.empty

let add_child = Query.add_child

let complete cs = Query.Next cs

let run = Run.run
