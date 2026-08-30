type expr =
  | Num of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let rec eval g = 
  match g with
  | Num e -> e
  | Add (a, b) -> eval a + eval b
  | Sub (a, b) -> eval a - eval b
  | Mul (a, b) -> eval a * eval b
  | Div (a, b) -> 
    let bv = eval b in 
    if bv = 0 then failwith "div 0"
    else eval a / bv


let e1 = Add (Num 1, Mul (Num 2, Num 3))   (* 1 + 2*3 = 7 *)
let e2 = Sub (Num 10, Num 4)                (* 10 - 4 = 6 *)
let e3 = Div (Num 12, Num 3)               (* 12 / 3 = 4 *)

let () = eval e1 |> string_of_int |> print_endline
let () = eval e2 |> string_of_int |> print_endline
let () = eval e3 |> string_of_int |> print_endline
