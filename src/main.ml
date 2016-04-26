(** Test *)

type bop = PlusMinus | Minus | Mul | Div

type uop = UMinus | Root

type exp =
  | Num of int
  | Var of string
  | Unop of uop * exp
  | Binop of bop * exp * exp

let string_of_binop = function
  | PlusMinus -> "+-"
  | Minus -> "-"
  | Mul -> "*"
  | Div -> "/"

let string_of_unop = function
  | UMinus -> "-"
  | Root -> "root"

(*
-b  +- root (b * b - 4 * a * c)
--------------------------------
2 * a
*)

let quadratic_formula =
  Binop ( Div
        , Binop ( PlusMinus
                , Unop (UMinus, Var "b")
                , Unop ( Root
                       , Binop ( Minus
                               , Binop (Mul, Var "b", Var "b")
                               , Binop ( Mul
                                       , Binop (Mul, Num 4, Var "a")
                                       , Var "c")
                               )
                       )
                )
        , Binop (Mul, Num 2, Var "a")
        )

module DM = Debugmode

let rec gen_query e =
  match e with
  | Num i -> DM.short (string_of_int i)
  | Var x -> DM.long (fun _ -> prerr_endline "very long result start"
                             ; prerr_endline x
                             ; prerr_endline x
                             ; prerr_endline "very long result end")
  | Unop (u, e1) ->
    DM.empty
    |> DM.add (string_of_unop u ^ " [a]rg") (fun _ -> gen_query e1)
    |> DM.node
  | Binop (b, e1, e2) ->
    let str_b = string_of_binop b in
    DM.empty
    |> DM.add (str_b ^ " [l]eft") (fun _ -> gen_query e1)
    |> DM.add (str_b ^ " [r]ight") (fun _ -> gen_query e2)
    |> DM.node

let _ = DM.run (gen_query quadratic_formula)
