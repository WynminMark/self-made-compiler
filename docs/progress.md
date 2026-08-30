# 学习进度

> 目标：用 OCaml 写编译器（哈佛 CS153 路线）。OCaml 基础够用即转入编译器，剩余特性按需学。
> 速查文档：[ocaml-basics.md](ocaml-basics.md)
> 记录格式：完成标 ✅，待办标 TODO，日期用绝对日期。

---

## 总体学习计划

编译器分阶段，每阶段需要的 OCaml 技能不同。✅ = 已掌握/完成，⬜️ = 待学。

| 阶段 | 内容 | 需要的 OCaml 技能 | 状态 |
|---|---|---|---|
| 0. 基础 | let/rec/函数/ADT/match/管道/异常 | 同左 | ✅ |
| 1. 词法分析 lexer | 把字符串切成 token 流 | ocamllex、正则规则、lexbuf | ⬜️ 第三课 |
| 2. 语法分析 parser | token 流 → AST | menhir（或手写递归下降）、文法、优先级 | ⬜️ 第四课 |
| 3. AST + 求值 | ADT 建模、递归 match | 已会 | ✅（第二课已练） |
| 4. 语义分析 / 类型检查 | 环境、符号表、类型推导 | `Map`/`Hashtbl`、`option`/`Result`、unification | ⬜️ |
| 5. 中间表示 + 优化 | IR、数据流分析 | 模块封装、不可变更新、`Set`/`Map` | ⬜️ |
| 6. 代码生成 | 选指令、格式化输出 | 字符串构造、模式匹配 | ⬜️ |

**开工判据（已达成）**：能定义 ADT 表示 AST、能用 `match` 递归处理、能用 `let rec`/`|>`/异常/异常/dune。剩余特性（模块系统、`option`/`Result`、`Map`/`Hashtbl`、ocamllex/menhir）在编译器推进中按需学，不阻塞开工。

---

## 第一课：OCaml 基础（2026-08-24）✅ 完成

- 学了：标识符大小写规则、关键字、`let`/`let rec`、函数、内置类型、ADT（变体/记录）、模式匹配、`option`、`|>` 管道
- 作业：[hello_ocaml/hello.ml](../hello_ocaml/hello.ml) —— `greet` + `greeting` ADT + `render` 模式匹配 + `|>` 打印。批改 A-，功能正确，风格可改进（`let ()` 入口、避免遮蔽、提取重复）
- 踩坑：构造子不是一等函数（`print_greeting Text` 报错，需 `fun s -> Text s` 包一层）；`==` vs `=`；`raise` 类型（`exn` 不是 string，用 `failwith`）

## 第二课：dune 工程 + 迷你计算器（2026-08-30）✅ 完成

### 任务 1：搭 dune 工程 ✅
- `hello_ocaml/` 升级成 dune 项目（`dune-project` + `dune`）
- 学了：`(name X)` 必须对应 `X.ml`、产物 `X.exe`（跨平台约定，Linux 也加）、`dune exec` 精确查找、警告默认当错误、`.mli` 接口匹配检查
- 踩坑：`dune exec ./hello`（缺 `.exe`）报 not found；`hello.mli` 声明了删掉的 `hello`/`hello_up` → 实现与接口不匹配

### 任务 2：迷你计算器 ✅
- [calc/calc.ml](../calc/calc.ml) —— `expr` ADT（`Num/Add/Sub/Mul/Div`）+ 递归 `eval` + 除零 `failwith`
- 批改 A，功能正确
- 踩坑：`raise "div 0"` 类型错（用 `failwith`）；`==` 应为 `=`；`eval b` 算两次（改用 `let bv = eval b in`）；`e |> print_endline` 类型错（`e : expr` 不是 string，要 `eval e |> string_of_int |> print_endline`）

### 选做：`Neg of expr` 一元负号 ✅
- 加构造子 + `eval` 补 `Neg e -> - (eval e)` 分支
- 体会：AST 加节点后 `match` 穷尽性检查会警告漏处理（OCaml 写编译器核心红利）
- 踩坑：`-eval e` 靠优先级蒙对（函数应用 > 一元负号），应加括号 `- (eval e)` 消歧义

---

## 第三课：词法分析 lexer TODO

### 概念

编译器前端流水线：
```
源码字符串 → [lexer] → token 流 → [parser] → AST → [语义分析] → ... → 代码生成
```
lexer 职责：把连续字符流切成一个个 token（带种类 + 可能的值）。

### token 建模（ADT）

```ocaml
type token =
  | INT of int       (* 整数字面量，携带数值 *)
  | PLUS | MINUS | STAR | SLASH
  | LPAREN | RPAREN
  | EOF
```
注意：lexer 阶段的 `MINUS` 只表示"看到 `-` 字符"，是减法还是负号由 parser 决定。

### 作业

**步骤 1（必做）：手写 tokenizer**

在 `calc2/` 建 dune 工程，写 `calc2.ml`：

1. 定义上面的 `token` 类型（先不加 `EOF`，列表形式不需要）
2. 手写 `tokenize : string -> token list`
   - 提示：`String.to_seq` 或按索引遍历字符
   - 多位数字要合并（`"123"` → `INT 123`，不是三个 `INT 1/2/3`）
   - 跳过空白
   - 非法字符 `failwith "unexpected char"`
3. 写 `string_of_token : token -> string` 方便打印
4. 测试：`tokenize "1 + 23 * 4"` 应得 `[INT 1; PLUS; INT 23; STAR; INT 4]`

**步骤 2（选做）：用 ocamllex**

写 `calc2_lex.mll`，用 ocamllex 规则实现同样功能，对比手写 vs 工具生成。

`.mll` 结构：
```ocaml
{
(* 头部：OCaml 代码 *)
}
rule token = parse
  | ['0'-'9']+  { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | '+'         { PLUS }
  | [' ' '\t']+ { token lexbuf }   (* 跳过空白，递归 *)
  | eof         { EOF }
{
(* 尾部 *)
}
```

### 验收
- `dune exec ./calc2.exe` 把 `"1 + 23 * 4"` 转成 `[INT 1; PLUS; INT 23; STAR; INT 4]` 并打印
- 多位数字、跳空白、非法字符报错

---

## 第四课：语法分析 parser TODO（第三课完成后展开）

- 学 menhir（比 ocamlyacc 现代），把 token 流变成 AST
- 文法、递归下降、优先级处理
- 产物：能 parse `"1 + 2 * 3"` 成 `Add (Num 1, Mul (Num 2, Num 3))`
- **结束时拥有能从字符串读入的计算器**

## 第五课：扩展计算器 → 小语言 TODO

- 加变量（符号表 → 学 `Hashtbl`/`Map`）
- 加 `if`/`let` 表达式（AST 扩展，体会穷尽性红利）
- 加函数定义和调用

## 第六课起：真正的编译器 TODO

- 类型系统、IR、代码生成
- 跟随 CS153 或编译器实现经典教材

---

## 待学的 OCaml 特性（按需补，不阻塞）

| 特性 | 何时需要 | 状态 |
|---|---|---|
| 模块系统（`module`/`struct`/`sig`/`.mli`） | 多文件编译器、封装 IR | ⬜️ |
| `option`/`Result` 错误处理 | parser 报错、查找可能失败 | ⬜️（`option` 概念已懂） |
| `Map`/`Hashtbl`/`Set` | 符号表、环境、数据流分析 | ⬜️ |
| ocamllex | 第三课 lexer | ⬜️ 即将学 |
| menhir | 第四课 parser | ⬜️ |
| `Printf.printf` 格式化 | 打印、代码生成 | 部分会 |
| 尾递归 / 累加器 | 深递归优化 | ⬜️ |
