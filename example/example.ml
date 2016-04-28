(* Example *)

type book =
  { title : string
  ; author: string
  ; contents_file : string
  }

type books = book list

let b1 =
  { title = "The happy"
  ; author = "Happy Alice"
  ; contents_file = "example/happy.txt"
  }

let b2 =
  { title = "The Strong"
  ; author = "Strong Bob"
  ; contents_file = "example/strong.txt"
  }

let head file_name n =
  let chan = open_in file_name in
  ( try
      for i = 1 to n do
        prerr_endline (input_line chan)
      done
    with End_of_file ->
      close_in chan;
      raise End_of_file
  );
  close_in chan
  

module DM = Debugmode

let author_query a = DM.short a

let contents_query f = DM.long (fun () -> head f 5)

let book_query b =
  DM.empty
  |> DM.add "[a]uthor" (fun _ -> author_query b.author)
  |> DM.add "content[s]" (fun _ -> contents_query b.contents_file)
  |> DM.node
     
let books_query =
  DM.empty
  |> DM.add b1.title (fun _ -> book_query b1)
  |> DM.add b2.title (fun _ -> book_query b2)
  |> DM.add "[h]ead"
     ( fun args ->
         match args with
           | [file_name; n] ->
             DM.long (fun () -> head file_name (int_of_string n))
           | _ -> invalid_arg "TRY: h example/happy.txt 3"
     )
  |> DM.node

let _ = DM.run books_query
