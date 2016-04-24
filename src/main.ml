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
  | Num i -> DM.create (string_of_int i)
  | Var x -> DM.create x
  | Unop (u, e1) ->
    DM.create (string_of_unop u)
    |> DM.add_child "[a]rg" (fun _ -> gen_query e1)
  | Binop (b, e1, e2) ->
    DM.create (string_of_binop b)
    |> DM.add_child "left_arg" (fun _ -> gen_query e1)
    |> DM.add_child "right_arg" (fun _ -> gen_query e2)

let _ = DM.run (gen_query quadratic_formula)
