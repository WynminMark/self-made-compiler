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

let string_of_token =
  let rec aux tokens =
    match tokens with
    | [] -> ""
    | INT n :: rest -> "INT(" ^ string_of_int n ^ ") " ^ aux rest
    | PLUS :: rest -> "PLUS " ^ aux rest
    | MINUS :: rest -> "MINUS " ^ aux rest
    | STAR :: rest -> "STAR " ^ aux rest
    | SLASH :: rest -> "SLASH " ^ aux rest
    | LPAREN :: rest -> "LPAREN " ^ aux rest
    | RPAREN :: rest -> "RPAREN " ^ aux rest
    | EOF :: rest -> "EOF" ^ aux rest
  in
  aux

let () =
  let input = "(1 + 23) * 4" in 
  input |> tokenize |> string_of_token |> print_endline

let () = 
  let i = 1 in
  let j = [2] in
  i::j |> List.iter (fun x -> print_int x; print_newline ())

