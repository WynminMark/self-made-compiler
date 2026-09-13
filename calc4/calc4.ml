open Tokens         (* expr 类型 *)
open Parser         (* token 类型 + main（menhir 生成）*)

let rec eval = function
  | Num n -> n
  | Add (a, b) -> eval a + eval b
  | Sub (a, b) -> eval a - eval b
  | Mul (a, b) -> eval a * eval b
  | Div (a, b) ->
      let bv = eval b in
      if bv = 0 then failwith "div 0"
      else eval a / bv
  | Neg e -> - (eval e)

(* 手写 lexer（复用 calc3 的，或直接用 ocamllex，这里先用旧的）*)

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

let parse input =
  let tokens = tokenize input in
  let pos = ref tokens in
  (* menhir 的 main 期望 lexbuf -> token，我们忽略 lexbuf，从 token 列表读 *)
  let lexer (_lexbuf : Lexing.lexbuf) : token =
    match !pos with
    | [] -> EOF
    | t :: rest -> pos := rest; t
  in
  (* dummy lexbuf 只是满足接口，menhir 用它跟踪位置，但我们不需要 *)
  let dummy_lexbuf = Lexing.from_string "" in
  Parser.main lexer dummy_lexbuf


let () =
  parse "1 + 2 * 3" |> eval |> string_of_int |> print_endline

let () = parse "1 + 2 * 3" |> eval |> string_of_int |> print_endline   (* 7 *)
let () = parse "(1 + 2) * 3" |> eval |> string_of_int |> print_endline (* 9 *)
let () = parse "10 - 2 - 3" |> eval |> string_of_int |> print_endline   (* 5，左结合 *)
let () = parse "-5 + 3" |> eval |> string_of_int |> print_endline
