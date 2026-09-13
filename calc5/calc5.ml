type token =
  | INT of int
  | PLUS | MINUS | STAR | SLASH
  | LPAREN | RPAREN
  | IDENT of string       (* 新：标识符，携带名字 *)
  | LET                    (* 新：关键字 let *)
  | IN                     (* 新：关键字 in *)
  | ASSIGN                 (* 新：= 号 *)
  | EOF


type expr =
  | Num of int
  | Add of expr * expr | Sub of expr * expr
  | Mul of expr * expr | Div of expr * expr
  | Neg of expr
  | Var of string              (* 新：变量引用，存名字 *)
  | Let of string * expr * expr (* 新：let x = e1 in e2，存变量名 + 两个表达式 *)


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
      | c when 'a' <= c && c <= 'z' || 'A' <= c && c <= 'Z' ->
          let start = pos in
          let rec find_end p =
            if p < String.length input && 
              (('a' <= input.[p] && input.[p] <= 'z') || 
               ('A' <= input.[p] && input.[p] <= 'Z') ||
               ('0' <= input.[p] && input.[p] <= '9')) 
               then find_end (p + 1)
            else
              p
          in
          let end_pos = find_end pos in
          let id_str = String.sub input start (end_pos - start) in
          let tok =
            match id_str with
            | "let" -> LET
            | "in" -> IN
            | _ -> IDENT id_str
          in
          aux end_pos (tok :: tokens)
      | '=' -> aux (pos + 1) (ASSIGN :: tokens)
      | _ -> failwith ("Unexpected character: " ^ String.make 1 input.[pos])
  in
  aux 0 []


let parse (input: string) : expr =
  let tokens = tokenize input in
  let pos = ref 0 in
  let current_token () = List.nth tokens !pos in
  let advance () = incr pos in

  let rec parse_expr () =
    let left = parse_term () in
    let rec loop left =
      match current_token () with
      | PLUS -> advance (); loop (Add (left, parse_term ()))
      | MINUS -> advance (); loop (Sub (left, parse_term ()))
      | _ -> left
    in
    loop left

  and parse_term () =
    let left = parse_factor () in
    let rec loop left =
      match current_token () with
      | STAR -> advance (); loop (Mul (left, parse_factor ()))
      | SLASH -> advance (); loop (Div (left, parse_factor ()))
      | _ -> left
    in
    loop left

  and parse_factor () = 
    match current_token () with
    | INT n -> advance (); Num n
    | MINUS -> advance (); Neg (parse_factor ())
    | LPAREN -> advance (); let e = parse_expr () in
                 (match current_token () with
                  | RPAREN -> advance (); e
                  | _ -> failwith "Expected closing parenthesis")
    | IDENT x -> advance (); Var x
    | LET -> advance ();
             (match current_token () with
              | IDENT x -> advance ();
                           (match current_token () with
                            | ASSIGN -> advance ();
                                        let e1 = parse_expr () in
                                        (match current_token () with
                                         | IN -> advance ();
                                                 let e2 = parse_expr () in
                                                 Let (x, e1, e2)
                                         | _ -> failwith "Expected 'in' after let binding")
                            | _ -> failwith "Expected '=' after let variable")
              | _ -> failwith "Expected identifier after 'let'")
    | _ -> failwith "Unexpected token in factor"
  in

  let result = parse_expr () in
  match current_token () with
  | EOF -> result
  | _ -> failwith "Unexpected token after expression"


let eval_top (e: expr) : int =
  let rec eval env e =
    match e with
    | Num n -> n
    | Add (e1, e2) -> eval env e1 + eval env e2
    | Sub (e1, e2) -> eval env e1 - eval env e2
    | Mul (e1, e2) -> eval env e1 * eval env e2
    | Div (e1, e2) -> eval env e1 / eval env e2
    | Neg e1 -> - (eval env e1)
    | Var x -> (try List.assoc x env with Not_found -> failwith ("Unbound variable: " ^ x))
    | Let (x, e1, e2) ->
        let v1 = eval env e1 in
        let new_env = (x, v1) :: env in
        eval new_env e2
  in
  eval [] e


let () = eval_top (parse "let x = 5 in x * 2") |> string_of_int |> print_endline
(* 10 *)
let () = eval_top (parse "let x = 1 in let x = x + 1 in x") |> string_of_int |> print_endline
(* 2，shadowing *)
let () = eval_top (parse "let x = 3 in let y = 4 in x * y") |> string_of_int |> print_endline
(* 12 *)


