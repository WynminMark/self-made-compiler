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
| 1. 词法分析 lexer | 把字符串切成 token 流 | ocamllex、正则规则、lexbuf | ✅ 第三课（手写完成，ocamllex 选做待补） |
| 2. 语法分析 parser | token 流 → AST | menhir（或手写递归下降）、文法、优先级 | ✅ 第四课（手写 + menhir 都完成） |
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

## 第三课：词法分析 lexer（2026-09-12）✅ 完成

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

### 步骤 1：手写 tokenizer ✅

- [calc2/calc2.ml](../calc2/calc2.ml) —— 手写 `tokenize : string -> token list`
- 用尾递归 `aux pos tokens`，`pos` 当游标、`tokens` 当累加器（头插 + `List.rev` 收尾）
- 多位数字：嵌套 `find_end` 递归找连续数字末尾，`String.sub` 取子串再 `int_of_string`
- 跳空白、非法字符 `failwith`、末尾加 `EOF`
- 批改 A：纯函数式尾递归写法地道。改进点：`string_of_token` 可用 `List.map` + `String.concat` 代替手写递归
- 输出：`tokenize "1 + 23 * 4"` → `[INT 1; PLUS; INT 23; STAR; INT 4]` ✅

### 步骤 2：用 ocamllex TODO（选做，未做）

留到以后练 ocamllex 工具时再做，对比手写 vs 工具生成。

### 期间补充的知识点
- 尾递归：递归调用是最后一步无后续计算，编译器优化成循环不溢出；累加器模式把"后续计算"提前算进参数
- list 单向链表：头插 O(1)、尾插 O(n)，故只提供 `::` 头插运算符；"头插 + `List.rev`"是 O(n) 模式
- 类型签名读法：`A -> B -> C -> D` 最右边是输出、左边全是输入（右结合 = 柯里化）
- 标准库扩充：[ocaml-basics.md §10](ocaml-basics.md) 补了 List/String/Array/Queue/Stack/Hashtbl/Map/Set/Seq 完整对比 + 每函数调用示例
- 类型推断：参数不用声明类型，编译器从调用处和函数体用法反推

---

## 第四课：语法分析 parser（2026-09-13）✅ 完成

### 概念

```
token 流：[INT 1; PLUS; INT 2; STAR; INT 3; EOF]
   ↓ parser（本课）
AST：    Add (Num 1, Mul (Num 2, Num 3))
   ↓ eval（第二课已会）
结果：   7
```
parser 职责：按语法规则把线性 token 流组装成树形 AST，处理**优先级**和**结合性**。
- `1 + 2 * 3` → `Add (Num 1, Mul (Num 2, Num 3))`（`*` 优先级高，先结合）
- `1 - 2 - 3` → `Sub (Sub (Num 1, Num 2), Num 3)`（左结合：`(1-2)-3 = -4`）

### 步骤 1：手写递归下降 ✅

- [calc3/calc3.ml](../calc3/calc3.ml) —— 串联 tokenize + parse + eval，从字符串读入计算器
- 文法三层：`expr`（加减）→ `term`（乘除）→ `factor`（数字/括号/负号），用 `and` 相互递归
- 游标模式：`pos = ref 0` + `current_token`/`advance`
- 左结合：`loop (Add (left, right))` 把累积 left 当新节点左子树
- 括号：`parse_factor` 遇 `(` 递归 `parse_expr` 回顶层
- 批改 A：四个测试 `7 / 9 / 5 / -2` 全过。改进点：`parse_expr/term/factor` 的 `tokens` 参数冗余（用闭包捕获外层 tokens 即可，可去掉）

### 步骤 2：menhir 重写 ✅

- [calc4/](../calc4/) —— `parser.mly` + `tokens.ml` + `calc4.ml`，dune 集成 menhir
- 学了：`.mly` 文法声明（`%token`/`%left`/`%prec`）、优先级自动解决冲突、`%prec NEG` 处理一元/二元冲突
- 输出同为 `7 / 7 / 9 / 5 / -2`（有个重复测试可删）

### 踩坑（menhir + dune 集成）
- **dune 不自动认 `.mly`**：要加 `(menhir (modules parser))` stanza，否则 `Unbound module Parser`
- **循环依赖**：`expr` 定义在 `calc4.ml`，但 `calc4.ml` 依赖 `Parser`（从 `.mly` 生成）→ menhir `--infer` 看不到 `expr`。修法：把 `expr` 移到独立的 `tokens.ml`
- **menhir 生成自己的 `token` 类型**：从 `tokens.ml` 删掉 `token`，`open Parser` 用 menhir 生成的
- **`Parser.main` 期望 `Lexing.lexbuf -> token`**：手写 tokenizer 返回 `token list`，要写桥接 `lexer (_lexbuf : Lexing.lexbuf) = ...` 忽略 lexbuf 从列表读 + 传 dummy lexbuf
- **`%precedence` 报 unknown directive**：换成 `%nonassoc`（功能等价）

### 期间补充的知识点
- menhir 指令清单 + ocamllex 介绍：[ocaml-basics.md §10.6](ocaml-basics.md)
- `t :: rest` 在模式位置（`->` 左边）是**拆解**不是头插；构造子造值/拆值用相同语法（对偶规则）
- 桥接手写 tokenizer 和 menhir 接口：`lexbuf` 是 ocamllex/menhir 间的数据载体，`Lexing.from_string` 造 lexbuf

---

## 第五课：扩展计算器 → 小语言 TODO

从"计算器"升级成"小语言"——加变量、控制流、函数。这是从玩具到真实编译器的关键一步，开始接触**环境（符号表）**、**作用域**、**闭包**等核心概念。

### 任务 1：加变量（环境 / 符号表）

- 扩展 token：`IDENT of string`（标识符）、`LET`、`ASSIGN`（`=`）
- 扩展 AST：`Var of string`（变量引用）、`Let of string * expr * expr`（let 绑定：`let x = e1 in e2`）
- 扩展 lexer：标识符正则 `['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9']*`、关键字识别
- 扩展 parser：变量声明和引用
- 扩展 eval：`eval : expr -> env -> int`，加 `env` 参数（变量名→值的映射）
  - `env` 用 `Hashtbl`（可变，简单）或 `(string, int) list`（不可变，函数式）
  - `Let (x, e1, e2)`：先 eval e1 得 v，把 (x, v) 加进 env，再 eval e2
  - `Var x`：从 env 查找 x 的值
- 测试：`let x = 5 in x * 2` → 10；`let x = 1 in let x = x + 1 in x` → 2（体会 shadowing）

### 任务 2：加控制流（`if` 表达式）

- 扩展 AST：`If of expr * expr * expr`（条件、then、else）
- 扩展 token/lexer/parser
- eval：`If (c, t, e)` → `if eval c <> 0 then eval t else eval e`
- 加布尔：要么用 int（0=false，非0=true），要么加 `bool` 类型
- 测试：`if 1 then 10 else 20` → 10；`let x = 5 in if x > 3 then 1 else 0` → 1
- 需要比较运算符 `>` `<` `=`，AST 加 `Gt/Lt/Eq`

### 任务 3（选做）：加函数定义和调用

- 扩展 AST：`Fun of string * expr`（lambda）、`App of expr * expr`（调用）
- 加 `let f x = e1 in e2` 语法糖
- eval：函数是闭包（捕获定义时的环境），调用时绑定参数
- 这是迈向函数式语言的关键。会涉及**闭包**和**词法作用域**
- 测试：`let f = fun x -> x + 1 in f 5` → 6；`let add = fun x -> fun y -> x + y in add 3 4` → 7（柯里化）

### 验收
- 变量能声明、引用、shadowing
- `if` 表达式能工作
- 理解环境怎么传递（`eval : expr -> env -> int` 的 env 参数）
- 思考：env 用 `Hashtbl`（可变）vs `(string, int) list`（不可变）的区别？函数式 vs 命令式的取舍

### 预期坑
- 作用域：`let x = e1 in e2` 里 x 只在 e2 可见，eval e2 后要"弹出" x（可变 Hashtbl）或用新环境（不可变 list）
- shadowing：`let x = ... in let x = ... in` 内层 x 不影响外层
- 关键字 vs 标识符：lexer 要先识别关键字（`let`/`if`/`then`/`else`），再当普通标识符
- 函数（任务3）的闭包：环境捕获时机（定义时还是调用时？词法作用域是定义时）

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
| ocamllex | 第三课 lexer | ⬜️ 选做待补（手写已会） |
| menhir | 第四课 parser | ✅ 第四课完成（手写 + menhir 都做了） |
| `Printf.printf` 格式化 | 打印、代码生成 | 部分会 |
| 尾递归 / 累加器 | 深递归优化 | ⬜️ |
