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

let rec gen_query e =
  match e with
  | Num i -> Query.create (string_of_int i)
  | Var x -> Query.create x
  | Unop (u, e1) ->
    let c1 = Query.create_child "[a]rg" (fun _ -> gen_query e1) in
    Query.create (string_of_unop u)
    |> Query.add_child c1
  | Binop (b, e1, e2) ->
    let c1 = Query.create_child "left_arg" (fun _ -> gen_query e1) in
    let c2 = Query.create_child "right_arg" (fun _ -> gen_query e2) in
    Query.create (string_of_binop b)
    |> Query.add_child c1
    |> Query.add_child c2

let main () =
  let q = gen_query quadratic_formula in
  Query.run q

let _ = main ()
