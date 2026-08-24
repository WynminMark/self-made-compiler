let greet name = "hello, " ^ "<" ^ name ^ ">!"

type greeting =
    | Text of string
    | Shout of string

let render g = 
    match g with
    | Text e -> e
    | Shout e -> String.uppercase_ascii e

let hello = 
    let s = greet "ocaml" in
    let s_text = Text s in
    render s_text |> print_endline

let hello_up = 
    let s = greet "ocaml" in
    let s_shout = Shout s in
    render s_shout |> print_endline


let print_greeting ctor =
  greet "ocaml" |> ctor |> render |> print_endline

let () = print_greeting Text
let () = print_greeting Shout