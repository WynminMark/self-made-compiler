type expr =
  | Num of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Neg of expr

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
  | Neg e -> - (eval e)


type token =
  | INT of int       (* 整数字面量，携带数值 *)
  | PLUS | MINUS | STAR | SLASH
  | LPAREN | RPAREN
  | EOF

let tokenize (input: string) : token list =
  let rec aux pos tokens =
    if pos >= String.length input then
      List.rev (EOF :: tokens)
    else
      match input.[pos] with
      | ' ' | '\t' | '\n' -> aux (pos + 1) tokens
      | '+' -> aux (pos + 1) (PLUS :: tokens)
      | '-' -> aux (pos + 1) (MINUS :: tokens)
      | '*' -> aux (pos + 1) (STAR :: tokens)
      | '/' -> aux (pos + 1) (SLASH :: tokens)
      | '(' -> aux (pos + 1) (LPAREN :: tokens)
      | ')' -> aux (pos + 1) (RPAREN :: tokens)
      | c when '0' <= c && c <= '9' ->
          let start = pos in
          let rec find_end p =
            if p < String.length input && '0' <= input.[p] && input.[p] <= '9' then
              find_end (p + 1)
            else
              p
          in
          let end_pos = find_end pos in
          let num_str = String.sub input start (end_pos - start) in
          let num = int_of_string num_str in
          aux end_pos (INT num :: tokens)
      | _ -> failwith ("Unexpected character: " ^ String.make 1 input.[pos])
  in
  aux 0 []

let parse (input: string) : expr =
  let tokens = tokenize input in
  let pos = ref 0 in
  let current_token () = List.nth tokens !pos in
  let advance () = incr pos in
  let rec parse_expr tokens =
    let left = parse_term tokens in
    let rec loop left =
      match current_token () with
      | PLUS -> advance (); loop (Add (left, parse_term tokens))
      | MINUS -> advance (); loop (Sub (left, parse_term tokens))
      | _ -> left
    in
    loop left
  and parse_term tokens =
    let left = parse_factor tokens in
    let rec loop left =
      match current_token () with
      | STAR -> advance (); loop (Mul (left, parse_factor tokens))
      | SLASH -> advance (); loop (Div (left, parse_factor tokens))
      | _ -> left
    in
    loop left
  and parse_factor tokens = 
    match current_token () with
    | INT n -> advance (); Num n
    | MINUS -> advance (); Neg (parse_factor tokens)
    | LPAREN -> advance (); let e = parse_expr tokens in
                 (match current_token () with
                  | RPAREN -> advance (); e
                  | _ -> failwith "Expected closing parenthesis")
    | _ -> failwith "Unexpected token in factor"
  in

  let result = parse_expr tokens in
  match current_token () with
  | EOF -> result
  | _ -> failwith "Unexpected token after expression"



let () = parse "1 + 2 * 3" |> eval |> string_of_int |> print_endline   (* 7 *)
let () = parse "(1 + 2) * 3" |> eval |> string_of_int |> print_endline (* 9 *)
let () = parse "10 - 2 - 3" |> eval |> string_of_int |> print_endline   (* 5，左结合 *)
let () = parse "-5 + 3" |> eval |> string_of_int |> print_endline       (* -2 *)
