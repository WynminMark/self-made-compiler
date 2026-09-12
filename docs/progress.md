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
| 2. 语法分析 parser | token 流 → AST | menhir（或手写递归下降）、文法、优先级 | ⬜️ 第四课（进行中） |
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

## 第四课：语法分析 parser TODO

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

### 核心方法：递归下降（手写 parser）

每个优先级层次写一个函数，互相递归调用。文法分层（低 → 高优先级）：

```
expr   ::= term (('+' | '-') term)*      (* 加减，最低优先级 *)
term   ::= factor (('*' | '/') factor)*  (* 乘除，较高 *)
factor ::= INT | '(' expr ')' | '-' factor  (* 数字、括号、一元负号，最高 *)
```

三个函数对应三层（用 `and` 连接，相互递归）：

```ocaml
let rec parse_expr tokens = ...    (* 解析加减，调 parse_term *)
and parse_term tokens = ...        (* 解析乘除，调 parse_factor *)
and parse_factor tokens = ...      (* 解析数字/括号/负号，遇 ( 递归调 parse_expr *)
```

**优先级体现在分层**：低优先级在顶层，调用时先解析高优先级，所以高优先级先结合。

### token 流读取：游标模式

```ocaml
let pos = ref 0
let peek () = List.nth tokens !pos    (* 看当前 token，不推进 *)
let advance () = incr pos              (* 消费当前 token *)
```

`peek` 看当前 token 决定怎么解析，`advance` 消费掉它。可变状态用 `let ... in` 限制在 `parse` 作用域内。

### 左结合的关键

`parse_expr` 的循环里把累积的 `left` 当新节点的左子树：

```ocaml
let rec loop left =
  match peek () with
  | PLUS -> advance ();
            let right = parse_term () in
            loop (Add (left, right))   (* 累积的 left 当新 Add 的左 → 左结合 *)
  | _ -> left
```

所以 `1 - 2 - 3` = `Sub (Sub (Num 1, Num 2), Num 3)` = `(1-2)-3 = -4`。

### 括号改变优先级

`parse_factor` 遇到 `(` 递归调 `parse_expr`（回到顶层），括号里的整个表达式被当成一个 factor：

```ocaml
| LPAREN -> advance ();
           let e = parse_expr () in   (* 递归回顶层 *)
           (match peek () with RPAREN -> advance () | _ -> failwith "expected )");
           e
```

所以 `(1 + 2) * 3` 里 `1 + 2` 被括号包成一个 factor，整体优先级高于外面的 `* 3`。

### 作业

在 `calc2/` 扩展或新建 `calc3/`，串联 `tokenize` + `parse` + `eval`，做从字符串读入的计算器：

1. 保留第三课的 `tokenize`
2. 保留第二课的 `expr` 类型和 `eval`（含 `Neg`）
3. 新增 `parse : string -> expr`，用递归下降三层
4. 入口测试：
   ```ocaml
   let () = parse "1 + 2 * 3" |> eval |> string_of_int |> print_endline   (* 7 *)
   let () = parse "(1 + 2) * 3" |> eval |> string_of_int |> print_endline (* 9 *)
   let () = parse "10 - 2 - 3" |> eval |> string_of_int |> print_endline   (* 5，左结合 *)
   let () = parse "-5 + 3" |> eval |> string_of_int |> print_endline       (* -2 *)
   ```

### 验收
- 四个测试输出 `7 / 9 / 5 / -2`
- 理解：`1 - 2 - 3` 为什么是 5（左结合 `(1-2)-3`）；括号怎么改变优先级（`parse_factor` 遇 `(` 递归 `parse_expr`）

### 预期坑
- `peek` 读到 `EOF` 时 `List.nth` 越界（tokenize 末尾加了 `EOF`，正好可处理）
- 忘了 `advance` 消费某 token → 死循环
- 忘了 `and` 连接三个相互递归函数

### 选做（有余力）
- 用 menhir 重写（工业级工具，了解 `.mly` 文法声明 + 优先级声明）

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
| ocamllex | 第三课 lexer | ⬜️ 选做待补（手写已会） |
| menhir | 第四课 parser | ⬜️ 选做待补（手写递归下降进行中） |
| `Printf.printf` 格式化 | 打印、代码生成 | 部分会 |
| 尾递归 / 累加器 | 深递归优化 | ⬜️ |
