let greet name = "hello, " ^ "<" ^ name ^ ">!"

type greeting =
    | Text of string
    | Shout of string

let render g = 
    match g with
    | Text e -> e
    | Shout e -> String.uppercase_ascii e

let print_greeting ctor =
  greet "ocaml" |> ctor |> render |> print_endline

let () = print_greeting (fun x -> Text x)
let () = print_greeting (fun x -> Shout x)

let () = greet "ocaml" |> (fun x -> Shout x) |> render |> print_endline