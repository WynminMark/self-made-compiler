val greet : string -> string
type greeting = Text of string | Shout of string
val render : greeting -> string
val print_greeting : (string -> greeting) -> unit
