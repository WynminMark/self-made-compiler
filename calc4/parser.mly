%{
  (* 头部：OCaml 代码，放 AST 类型和辅助函数 *)
  open Tokens
%}

(* token 声明：告诉 menhir 有哪些 token *)
%token <int> INT            (* 带值的 token：<int> 是携带的类型 *)
%token PLUS MINUS STAR SLASH
%token LPAREN RPAREN
%token EOF                  (* 输入结束 *)

(* 起点符号：整个输入解析成一个 expr *)
%start <expr> main          (* <expr> 是 main 的返回类型 *)

(* 优先级声明：从低到高 *)
%left PLUS MINUS            (* 左结合，优先级低 *)
%left STAR SLASH            (* 左结合，优先级高 *)
%nonassoc NEG             (* 一元负号的"伪优先级"，最高。nonassoc = 不指定结合性 *)

%%

(* 规则段：文法 *)

main:
  | e = expr EOF { e }      (* 整个输入 = 一个 expr 加 EOF *)

expr:
  | e1 = expr PLUS e2 = expr   { Add (e1, e2) }     (* 左结合由 %left 决定 *)
  | e1 = expr MINUS e2 = expr  { Sub (e1, e2) }
  | e1 = expr STAR e2 = expr   { Mul (e1, e2) }
  | e1 = expr SLASH e2 = expr  { Div (e1, e2) }
  | MINUS e = expr %prec NEG   { Neg (e) }            (* %prec NEG：这个 MINUS 用 NEG 优先级 *)
  | n = INT                    { Num n }
  | LPAREN e = expr RPAREN     { e }

%%
