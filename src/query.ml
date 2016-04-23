(** Query *)

module CmdKey = struct

  type t =
    | CKeyNum of int
    | CKeyStr of string
    | CKeyUp
    | CKeyExit

  let compare = compare

  let count = ref 0                     (* TODO: count for each query *)

  let new_count () = count := !count + 1; !count

  let make_from_str s =
    if Str.string_match (Str.regexp "\\[\\([a-zA-Z]+\\)\\]") s 0 then
      CKeyStr (Str.matched_group 1 s)
    else
      CKeyNum (new_count ())

  let make_from_cmd s =
    if s = "^" then CKeyUp else
    if s = "x" || s = "X" then CKeyExit else
      match int_of_string s with
      | n -> CKeyNum n
      | exception (Failure "int_of_string") -> CKeyStr s

  let string_of = function
    | CKeyNum i -> string_of_int i
    | CKeyStr s -> s
    | CKeyUp -> "^"
    | CKeyExit -> "x"

  let prerr x = prerr_string (string_of x)

end

module Childs = Map.Make (CmdKey)

type t =
  { content : string
  ; childs : child_t Childs.t
  }

and child_t =
  { name : string
  ; f : string list -> t
  }

let create c = {content = c; childs = Childs.empty}

let create_child n f = {name = n; f = f}

let add_child c q =
  {q with childs = Childs.add (CmdKey.make_from_str c.name) c q.childs}

module State = struct

  type state_t = t list

  let empty = []

  let rec prerr_rev = function
    | [] -> ()
    | q :: tl ->
      prerr_string q.content;
      prerr_string " > ";
      prerr_rev tl

  let prerr s = prerr_rev (List.rev s)

  let prerr_endline s =
    prerr s;
    prerr_newline ()

end

let prerr_child_option k child_q =
  CmdKey.prerr k;
  prerr_string " : ";
  prerr_endline child_q.name

let prerr_child_options child_qs =
  Childs.iter prerr_child_option child_qs

let get_cmd_args s =
  match Str.split (Str.regexp "[ \t]+") s with
  | [] -> None
  | c :: args -> Some (CmdKey.make_from_cmd c, args)

let prerr_invalid_input () = prerr_endline "Invalid input"

let rec process s q =
  State.prerr s;
  prerr_endline q.content;
  prerr_child_options q.childs;
  process_cmd (q :: s) q.childs

and process_cmd s qs =
  match read_line () |> get_cmd_args with
  | Some (cmd, args) ->
    ( match cmd with
      | CmdKey.CKeyNum _
      | CmdKey.CKeyStr _ ->
        if not (Childs.mem cmd qs) then
          ( prerr_invalid_input ()
          ; process_cmd s qs )
        else
          let q = Childs.find cmd qs in
          let child_q = q.f args in
          process s child_q
      | CmdKey.CKeyUp ->
        ( match s with
          | _ :: q :: tl -> process tl q
          | _ -> ()
        )
      | CmdKey.CKeyExit -> ()
    )
  | None ->
    ( prerr_invalid_input ()
    ; process_cmd s qs )

let run q =
  prerr_endline "Start debug mode.";
  process State.empty q;
  prerr_endline "Bye debug mode!"

