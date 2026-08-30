# OCaml 基础速查表

> 面向"有编程基础、正在学写编译器"的读者。重点标注**关键字**与**自己起的名字**的区别。
>
> 约定：
> - `关键字` —— 语言保留字，不能当变量名，下文用 **粗体** 标注。
> - `自起名` —— 你自己命名的标识符，下文用普通字体。
> - 所有示例的逐字标注见每段下方的"逐字解析"。

---

## 0. 标识符大小写规则（最重要）

OCaml 用**大小写**来区分一个名字属于哪一类，这是硬规则：

| 类别 | 大小写要求 | 例子 |
|---|---|---|
| 构造子（variant constructor） | **大写字母开头** | `Circle`、`Some`、`Text` |
| 变量名、函数名 | 小写字母开头 | `greet`、`factorial`、`n` |
| 类型名（type 名） | 小写字母开头 | `shape`、`person`、`expr` |
| 记录字段名 | 小写字母开头 | `name`、`age`、`line` |
| 模块名 | 大写字母开头 | `String`、`List`、`MyModule` |

> 记住一句口诀：**大写 = 构造子/模块；小写 = 变量/类型/字段。**
> 看到一个大写开头的标识符，它一定是构造子或模块名；看到小写开头的一定是变量、类型或字段。

---

## 1. 关键字清单

以下是常用**真·关键字**（保留字，不能当变量名）：

```
let  in  rec  fun  type  of  match  with  if  then  else
true  false  module  struct  sig  end  begin  do  done
function  when  exception  try  raise  mutable  ref  and  or  mod  not
```

**不是关键字**、但容易混淆的：

| 名字 | 性质 | 说明 |
|---|---|---|
| `int` `string` `float` `bool` `char` `unit` `list` `option` | 内置类型 | 预定义的普通类型名，**不是**关键字 |
| `print_endline` `String.uppercase_ascii` | 库函数 | 普通函数，不是关键字 |
| `Some` `None` `true` `false` | 构造子 | `true`/`false` 其实是内置构造子；`Some`/`None` 是 option 类型的构造子 |

> `true` / `false` 在语法上表现得像关键字，但严格说它们是 `bool` 类型的两个构造子。初学当成"字面量"即可。

---

## 2. let —— 万物皆绑定

OCaml 里没有"变量赋值"，只有"把名字绑定到值"。**不可变**是默认。

### 顶层绑定（声明，全局）

```ocaml
let x = 3 + 4
```

逐字解析：`let`**关键字** `x`自起名 `=`符号 `3 + 4`表达式。

### 局部绑定（表达式，有值）

```ocaml
let area =
  let pi = 3.14 in
  let r = 2.0 in
  pi *. r *. r
```

逐字解析：内层的 `let ... in`**关键字组合** 定义局部名字，作用域到表达式结尾；外层 `let area = ...`是顶层绑定。

> 关键区分：
> - `let x = e` —— 顶层声明（无 `in`）
> - `let x = e in e'` —— 局部绑定表达式（有 `in`）
>
> `in` 是关键字，标志"这是一个表达式"。

---

## 3. let rec —— 递归

`let` 和 `rec` **都是关键字**。

- `let` = 定义名字
- `rec` = 关键字 "recursive"，告诉编译器"定义体内可以引用自己"

```ocaml
let rec factorial n =
  if n <= 1 then 1 else n * factorial (n - 1)
```

不加 `rec` 而自引用会报错。这是 OCaml 的设计：**递归必须显式声明**，不允许偷偷递归。

> 多个相互递归的函数用 `and` 关键字连接：
> ```ocaml
> let rec is_even n = if n = 0 then true else is_odd (n - 1)
> and is_odd n = if n = 0 then false else is_even (n - 1)
> ```
> `and` 是关键字。

---

## 4. 函数

定义函数**没有专门关键字**，`let` 后面跟参数就是函数：

```ocaml
let add x y = x + y           (* 两参数函数 *)
let add' = fun x y -> x + y   (* 等价：fun 是关键字，-> 是符号 *)
let inc = add 1               (* 部分应用：inc 是吃一个参数的函数 *)
```

逐字解析：
- `add`自起函数名 `x y`自起参数名（小写）
- `fun`**关键字**，匿名函数；`->`符号

调用规则：
- **不加括号**：`add 1 2`，不是 `add(1, 2)`
- 参数用空格分隔
- 每个函数其实只吃一个参数，"多参数"是柯里化语法糖
- 运算符也是函数：`(+)` `(^)` `(+.)`

---

## 5. 内置类型与字面量

```ocaml
let n = 3            (* int —— 整数字面量 *)
let f = 3.0          (* float —— 必须带 .0 *)
let s = "abc"        (* string —— 双引号 *)
let c = 'a'          (* char —— 单引号 *)
let b = true         (* bool —— true/false *)
let l = [1; 2; 3]    (* int list —— 分号分隔，不是逗号！ *)
let t = (1, "x")     (* int * string —— 元组，逗号分隔 *)
let u = ()           (* unit —— 只有一个值 ()，类似 void *)
```

### 类型标注（可选，编译器能推断）

```ocaml
let add (x : int) (y : int) : int = x + y
```

- `:` 符号引入类型标注
- 返回类型标注写在 `=` 前

### 运算符与类型严格对应

| 运算符 | 适用类型 | 例 |
|---|---|---|
| `+ - * /` | int | `1 + 2` |
| `+. -. *. /.` | float | `1.0 +. 2.0` |
| `^` | string | `"a" ^ "b"` |
| `::` | list 头插 | `1 :: [2]` |
| `@` | list 拼接 | `[1] @ [2]` |
| `=` `<>` | 任意（结构相等） | `1 = 1` |
| `&&` `\|\|` | bool | `true && false` |
| `\|>` | 管道：左边的值喂给右边的函数 | `s \|> print_endline` |
| `@@` | 反管道：低优先级函数应用 | `f @@ g x` |

> 陷阱：`+` 不能用于 float，`+.` 不能用于 int，`^` 不能用于 int。类型不符直接编译报错。

### 管道运算符 `|>`（重点）

写 OCaml 几乎离不开 `|>`。它把左边的结果作为参数喂给右边的函数：

```ocaml
x |> f        (* 等价于 f x *)
```

定义很简单（标准库已内置）：
```ocaml
let (|>) x f = f x
```

**为什么要用它？** 两个作用：① 链式调用从内到外写成从上到下，可读性暴增；② 强制把左边当成"一个整体"喂给右边的函数，避免柯里化解析歧义。

**链式写法对比**（写编译器时大量出现）：

```ocaml
(* 不用管道：从内到外嵌套，难读 *)
print_endline (render (Text (greet "ocaml")))

(* 用管道：从上到下流水线，清晰 *)
greet "ocaml" |> Text |> render |> print_endline
```

后者的读法："把 `greet "ocaml"` 的结果，交给 `Text` 包装，再交给 `render` 渲染，最后交给 `print_endline` 打印"。一气呵成。

**关键：优先级。** 函数应用（`f x`，空格）优先级**最高**、最贪心；中缀运算符（`|>`、`+`、`^`、`::`）优先级较低。所以：

```ocaml
render s_text |> print_endline
```

解析顺序：
1. 先处理函数应用：`render s_text` → 一个 `string`（`render` 只吃 `s_text` 这一个参数 ✅）
2. 再处理 `|>`：把上一步的 string 喂给 `print_endline`

等价于 `print_endline (render s_text)`。`|>` 起到了"把 `render s_text` 强制包成整体"的作用。

**陷阱：不用管道也不加括号会错**：

```ocaml
print_endline render s_text       (* 报错！ *)
```

按优先级，函数应用贪心 → 解析成 `print_endline` 吃了**两个**参数 `render` 和 `s_text`。但 `print_endline : string -> unit` 只吃一个 string，报错：

```
Error: This function has type string -> unit
       It is applied to too many arguments
```

报错可能指向中间的 `render`，不要被误导——**根因是整个调用结构错了**，少了 `|>` 或括号。

**三种正确等价写法**：

```ocaml
print_endline (render s_text)     (* 括号：显式一元应用 *)
render s_text |> print_endline   (* 管道：最地道 *)
print_endline @@ render s_text   (* @@ 是反管道，低优先级应用 *)
```

> `|>` 从左往右流（数据 → 函数）；`@@` 从右往左应用（函数 @@ 数据）。日常用 `|>` 居多。

**构造子进管道的陷阱**：构造子能用来构造值（`Text "hi"`），也能在管道中间环节出现（`greet "ocaml" |> (fun s -> Text s) |> render`）。但**构造子不是一等函数**——不能把裸 `Text` 当 `string -> greeting` 的函数值传递：

```ocaml
(* ❌ 错：构造子不能当函数值传 *)
let print_greeting ctor =
  greet "ocaml" |> ctor |> render |> print_endline
let () = print_greeting Text       (* Error: This expression should not be a constructor *)

(* ✅ 对：用 lambda 包一层 *)
let () = print_greeting (fun s -> Text s)
let () = print_greeting (fun s -> Shout s)
```

报错信息：`This expression should not be a constructor, the expected type is string -> greeting`。这是 OCaml 的经典坑：构造子只能构造值，不能当函数值传递。需要函数值时写 `fun x -> 构造子 x` 包一层。

> 口诀：**`f x y`（空格）= `f` 贪心吃多参数；`x |> f` = `x` 作为唯一参数喂给 `f`。** 写编译器时 AST 变换一路 `|>` 下去是常态。

---

## 6. 代数数据类型（ADT）

由关键字 `type` 引出。两类：**变体**（或）和**记录**（与）。

### 6.1 变体 variant —— "或"关系

表示"这个值是 A **或** B **或** C 之一"。

```ocaml
type shape =
  | Circle of float
  | Rect of float * float
  | Triangle of float * float * float
```

逐字解析：
- `type`**关键字**，开始定义类型
- `shape`自起类型名（**小写**开头）
- `|` 符号，分隔构造子（第一个可省略 `|`）
- `Circle` `Rect` `Triangle`自起构造子名（**大写**开头，硬规则）
- `of`**关键字**，"携带数据"
- `float`、`float * float`内置类型，`*` 表示元组"和"

构造：
```ocaml
let c = Circle 3.0
let r = Rect (2.0, 4.0)
```

带参数的构造子像函数调用：`Circle 3.0`，不加括号（多参数用元组 `Rect (2.0, 4.0)`）。

### 6.2 记录 record —— "与"关系

表示"这个值**同时**有 A、B、C 字段"。

```ocaml
type person = {
  name : string;
  age : int
}
```

逐字解析：
- `type`**关键字**
- `person`自起类型名（小写）
- `{ }` 符号
- `name` `age`自起字段名（**小写**开头）
- `:` 符号引入类型标注
- `;` 符号分隔字段（不是逗号）

构造与访问：
```ocaml
let p = { name = "alice"; age = 30 }
let n = p.name        (* . 访问字段 *)
let p2 = { p with age = 31 }   (* with 关键字，函数式更新 *)
```

`with` 是关键字，表示"复制并修改某些字段"。

### 6.3 变体 vs 记录

| | 变体 variant | 记录 record |
|---|---|---|
| 逻辑关系 | 或（取其一） | 与（全都有） |
| 例子 | shape = Circle \| Rect | person = {name; age} |
| 名字大小写 | 构造子**大写** | 字段名**小写** |
| 取值方式 | 模式匹配 | `.` 字段访问 |
| 编译器用途 | AST 节点种类 | 符号表条目、位置信息 |

### 6.4 带参数类型（泛型）

类型名后用 `'a`（类型参数，单引号开头）：

```ocaml
type 'a mylist =
  | Empty
  | Cons of 'a * 'a mylist
```

`'a` 是类型变量（不是关键字），读作"alpha"。

### 6.5 类型名 vs 构造子：它们各自的作用

初学常疑惑："模式匹配分支用的是构造子 `Text`/`Shout`，从没用到类型名 `greeting`，那类型名有什么用？"

**核心：类型名是给"整个类型"起的名（类型层面），构造子是给"每种取值"起的名（值层面）。两者层次不同。**

- `greeting` —— 类型名，回答"这是什么类型的东西？"
- `Text` / `Shout` —— 构造子，回答"这是这个类型里的哪一种？"

模式匹配是**值层面**操作（区分这个值是 `Text` 还是 `Shout`），所以用构造子，不用类型名——这很正常。

类型名主要用在以下场景：

**① 类型标注**（最常见，类型标注必须用类型名，不能用构造子）：
```ocaml
let render (g : greeting) : string = ...   (* greeting 是类型名 *)
let parse s : greeting = ...                 (* 返回类型用类型名 *)
```

**② 模块签名 / 接口**（写编译器必备，`.mli` 里暴露类型）：
```ocaml
(* ast.mli *)
type expr                                   (* 暴露类型名 *)
val eval : expr -> int                      (* 签名里用类型名 *)
```

**③ 跨函数/模块共享同一类型**：多个函数处理同一种 AST 时，靠类型名把它们串起来。代码小的时候"看起来没用"，一旦跨模块共享 AST，类型名就是命脉。

**④ 构造子消歧**：当不同类型都有同名构造子时，类型名帮编译器确认它属于哪个类型。

**⑤ 类型别名**：
```ocaml
type expr = greeting      (* expr 现在和 greeting 是同一种类型 *)
```

> 类比：**类型名 = 身份证上的"民族"**（你是 greeting 族）；**构造子 = 具体那个人**（Text 某、Shout 某）。查户口（模式匹配）时问"具体哪个人"（构造子）；填表格（类型标注）时写"民族"（类型名）。
>
> 写编译器时 AST 的类型名（`expr`、`stmt`、`ty`）会被反复用在 `.mli` 签名、类型标注、别名里——那时就体会到它的作用。

---

## 7. 模式匹配 match

配合变体使用，**表达式**，有值。

```ocaml
let rec eval e =
  match e with
  | Num n -> n
  | Add (a, b) -> eval a + eval b
  | Mul (a, b) -> eval a * eval b
```

逐字解析：
- `match` `with`**关键字**对
- `|` 符号分隔分支
- `->` 符号，左边模式、右边结果
- `Num` `Add` `Mul`构造子（大写），`n` `a` `b`自起变量名（小写，绑定子数据）

### 通配符与守卫

```ocaml
let describe n =
  match n with
  | 0 -> "zero"
  | x when x > 0 -> "positive"   (* when 关键字，守卫条件 *)
  | _ -> "negative"              (* _ 通配符，匹配任意 *)
```

- `_` 下划线，通配符（不是关键字，是特殊模式）
- `when`**关键字**，给分支加条件

### 穷尽性检查

编译器会检查是否覆盖所有构造子。漏掉一个会警告 `non-exhaustive`。这对编译器写作极友好——加了新 AST 节点会立刻提示哪里没处理。

### 分支与构造子的关系（不必一一对应）

编译器要求的不是"分支和构造子一一对应"，而是 **穷尽**：每个值至少被一个分支覆盖。满足这点，分支数量和写法都很自由。

**分支少于构造子数 —— 合并（or-pattern）**：
```ocaml
let inner g =
  match g with
  | Text s | Shout s -> s      (* 两个构造子共用一个分支，要求两侧绑定同名变量 *)
```

**通配符兜底**：
```ocaml
let is_shout g =
  match g with
  | Shout _ -> true      (* _ 匹配任意值但不绑定名字 *)
  | _ -> false           (* 第二个 _ 覆盖 Text，穷尽 *)
```

**分支多于构造子数 —— 细化（对内部数据提要求）**：
```ocaml
let render g =
  match g with
  | Text "" -> "(empty)"               (* 只匹配内部是空串的 Text *)
  | Text s -> s
  | Shout s when s = "" -> "(EMPTY!)"  (* when 守卫加条件 *)
  | Shout s -> String.uppercase_ascii s
```
这里 `Text` 一个构造子占了两个分支。合法，且穷尽。

**顺序重要**：匹配从上到下 **先到先得**。`Text ""` 必须写在 `Text s` 之前，否则永远轮不到它（写反了编译器会警告 `unused pattern`）。

**漏写会怎样**：
```ocaml
let render g = match g with
  | Text s -> s
(* Warning: this pattern-matching is not exhaustive.
   Here is an example of a case that is not matched: Shout _ *)
```
若不理会警告、运行时真传进来 `Shout _`，程序崩：`Match_failure`。

**写编译器时的红利**：AST 加了新构造子（如 `Sub`），重新编译时**所有**忘了处理 `Sub` 的 `match`（parser、evaluator、printer…）全部冒警告，等于编译器免费做全局影响分析。这是 OCaml 写编译器的核心优势之一。

> 总结：编译器要求"人人有分支"（穷尽），不要求"分支贴着构造子写"（可合并、可细化、可兜底）。

---

## 8. 元组与列表

### 元组（固定长度、可异构）

```ocaml
let t : int * string = (1, "a")
let (n, s) = t       (* 解构：模式匹配元组 *)
```

`*` 在类型层面表示元组组件；`,` 在值层面分隔元组成员。

### 列表（可变长度、同构）

```ocaml
let l = [1; 2; 3]    (* 分号分隔 *)
let l2 = 0 :: l      (* :: 头插，右结合 *)
let l3 = l @ l2      (* @ 拼接 *)
let rec len = function
  | [] -> 0
  | _ :: rest -> 1 + len rest
```

- `[]` 空列表
- `::` 构造子（其实是中缀构造子），把元素加到列表头
- `function`**关键字**，等价于 `fun x -> match x with ...`

---

## 9. option 类型（内置变体）

处理"可能没有值"的情况，代替 null。

```ocaml
type 'a option =
  | None
  | Some of 'a
```

`None` / `Some` 是内置构造子（大写开头）。`option` 是内置类型名。

```ocaml
let find_opt k alist =
  match List.assoc_opt k alist with
  | Some v -> v
  | None -> 0   (* 缺省值 *)
```

---

## 10. 可变性（命令式特性，了解即可）

默认不可变。需要可变时：

```ocaml
let counter = ref 0          (* ref 关键字，可变引用 *)
let () = incr counter         (* incr 是函数：ref int -> unit *)
let n = !counter              (* ! 前缀：取 ref 的值 *)
```

- `ref`**关键字**，创建可变引用
- `!` 前缀运算符，解引用
- `mutable`**关键字**，标记记录字段可变：
  ```ocaml
  type counter = { mutable n : int }
  let c = { n = 0 }
  let () = c.n <- c.n + 1     (* <- 赋值符号 *)
  ```

---

## 11. 模块（简述）

OCaml 用模块组织代码，模块名**大写开头**。

```ocaml
module type STACK = sig           (* module type sig 关键字：接口 *)
  type 'a t
  val push : 'a -> 'a t -> 'a t  (* val 关键字：声明值签名 *)
end

module ListStack : STACK = struct  (* module struct 关键字：实现 *)
  type 'a t = 'a list
  let push x s = x :: s
end
```

- `module` `struct` `sig` `end` `val`**关键字**
- `ListStack`自起模块名（大写）
- `t` 约定俗成的"主类型名"

---

## 12. 注释

```ocaml
(* 单行注释 *)

(*
  多行注释
  (* 可以嵌套！这是 OCaml 特色 *)
*)
```

`(*` `*)` 是注释符号，**可嵌套**（C/Java 的 `/* */` 不能嵌套）。

---

## 13. 运行一个程序

### 顶层入口

OCaml 程序的入口是顶层的 `let () = ...`（或 `let main = ...`）：

```ocaml
let () =
  print_endline "hello, ocaml!"
```

`let () =` 表示"这是一个无返回值的顶层副作用声明"（返回 `unit`）。这是约定俗成的 main 写法。

### 最简运行

```bash
ocaml hello.ml          (* 直接解释运行 *)
ocamlfind ocamlopt -package str hello.ml -o hello   (* 编译成可执行 *)
```

### 用 dune（推荐，写编译器项目用这个）

工程目录：
```
hello_ocaml/
├── dune-project      # 内容: (lang dune 3.0)
├── dune              # 构建规则
└── hello.ml
```

`dune` 文件内容：
```
(executable
 (name hello))
```

运行：
```bash
dune exec ./hello.exe    # 编译并运行
dune build              # 只编译
```

---

## 14. 速记口诀

- **大写 = 构造子/模块；小写 = 变量/类型/字段**
- `let` 定义，`let ... in` 局部表达式，`let rec` 递归
- 函数不加括号，参数用空格
- `int` 用 `+`，`float` 用 `+.`，`string` 用 `^`
- 列表用分号 `[1; 2; 3]`，元组用逗号 `(1, "a")`
- `x |> f` 把 `x` 作为唯一参数喂给 `f`；`f x y`（空格）贪心吃多参数——别混淆
- `type` 定义类型，变体用 `|` 构造子（大写），记录用 `{ 字段 : 类型 }`
- `match ... with` 模式匹配，编译器查穷尽性
- 递归必须 `rec`，不能偷偷自引用
- `()` 是 unit，`let () = ...` 是 main 入口

---

## 附：常用关键字一览表

| 关键字 | 作用 |
|---|---|
| `let` | 绑定名字 |
| `in` | 局部绑定表达式 |
| `rec` | 允许递归自引用 |
| `fun` | 匿名函数 |
| `function` | `fun + match` 简写 |
| `type` | 定义类型 |
| `of` | 变体携带数据 |
| `|` | 分隔变体/匹配分支（符号） |
| `match` `with` | 模式匹配 |
| `when` | 匹配守卫 |
| `if` `then` `else` | 条件 |
| `true` `false` | bool 构造子 |
| `module` `struct` `sig` `end` | 模块定义/接口 |
| `val` | 模块签名中的值声明 |
| `begin` `end` | 等价于 `( )`，分组 |
| `do` `done` | 循环体 |
| `try` `exception` `raise` | 异常 |
| `mutable` `ref` | 可变性 |
| `and` | 多绑定连接/相互递归 |
| `mod` `not` `or` | 运算符关键字 |
