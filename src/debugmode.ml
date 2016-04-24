(** Debugmode *)

module Cmd = struct

  type t =
    | CNum of int
    | CStr of string
    | CUp
    | CExit

  let compare = compare

  let make_from_str i s =
    if Str.string_match (Str.regexp "\\[\\([a-zA-Z]+\\)\\]") s 0 then
      (i, CStr (Str.matched_group 1 s))
    else
      (i + 1, CNum i)

  let make_from_cmd s =
    if s = "^" then CUp else
    if s = "x" || s = "X" then CExit else
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
    | CExit -> "x"

  let prerr x = prerr_string (string_of x)

end

module Query = struct

  module Childs = Map.Make (Cmd)

  type t =
    { content : string
    ; childs : child_t Childs.t
    ; i : int
    }

  and child_t =
    { name : string
    ; f : string list -> t
    }

  let create c = {content = c; childs = Childs.empty; i = 0}

  let add_child n f q =
    let c = {name = n; f = f} in
    let (i', cmd) = Cmd.make_from_str q.i n in
    { q with
      childs = Childs.add cmd c q.childs
    ; i = i'
    }

  let find_child cmd cs =
    match Childs.find cmd cs with
    | q -> Some q
    | exception _ -> None

  let prerr_content q = prerr_string q.content

  let prerr_child k child_q =
    Cmd.prerr k;
    prerr_string " : ";
    prerr_endline child_q.name

  let prerr_childs cs = Childs.iter prerr_child cs

end

module State = struct

  type state_t = Query.t list

  let empty = []

  let rec prerr_rev = function
    | [] -> ()
    | q :: tl ->
      Query.prerr_content q;
      prerr_string " > ";
      prerr_rev tl

  let prerr s = prerr_rev (List.rev s)

  let prerr_endline s q =
    prerr_string "STATE : ";
    prerr s;
    Query.prerr_content q;
    prerr_newline ()

end

module Run = struct

  let prerr_invalid_input () = prerr_endline "Invalid input"

  let rec process s q =
    State.prerr_endline s q;
    Query.prerr_childs q.Query.childs;
    process_cmd (q :: s) q.Query.childs

  and process_cmd s qs =
    prerr_string "$ ";
    flush stderr;
    match read_line () |> Cmd.get_cmd_args with
    | Some (cmd, args) ->
      ( match cmd with
        | Cmd.CNum _
        | Cmd.CStr _ ->
          ( match Query.find_child cmd qs with
            | Some c ->
              let child_q = c.Query.f args in
              process s child_q
            | None ->
              ( prerr_invalid_input ()
              ; process_cmd s qs )
          )
        | Cmd.CUp ->
          ( match s with
            | _ :: q :: tl -> process tl q
            | _ -> ()
          )
        | Cmd.CExit -> ()
      )
    | None ->
      ( prerr_invalid_input ()
      ; process_cmd s qs )

  let run q =
    prerr_endline "Start debug mode.";
    process State.empty q;
    prerr_endline "Bye debug mode!"

end

let create = Query.create

let add_child = Query.add_child

let run = Run.run
