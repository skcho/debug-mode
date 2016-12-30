(* Example *)

module DM = Debugmode

type t =
  { name : string
  ; hobby : string }

let name_query d = DM.short d.name

let hobby_query n d =
  DM.long
    ( fun () ->
        for i = 1 to n do
          prerr_endline d.hobby
        done )

let query d =
  DM.empty
  |> DM.add "name" (fun _ -> name_query d)
  |> DM.add "[h]obby"
    ( function
      | [] -> hobby_query 1 d
      | n_str :: _ ->
        ( match int_of_string n_str with
          | n -> hobby_query n d
          | exception _ -> failwith "USAGE: h ?number" )
    )
  |> DM.final

let data =
  { name = "Alice"
  ; hobby = "programming" }

let _ = DM.run (query data)
