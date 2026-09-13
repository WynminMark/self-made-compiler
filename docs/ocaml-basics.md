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

## 10. 常用标准库函数（List / String 等）

OCaml 标准库按模块组织，模块名**大写开头**（`List`、`String`、`Array`…）。模块里的函数用 `模块名.函数名` 调用，如 `List.map`、`String.length`。这些**不是关键字**，是预定义的普通函数。

### 10.1 List 模块（列表操作，最常用）

| 函数 | 类型 | 作用 |
|---|---|---|
| `List.map` | `('a -> 'b) -> 'a list -> 'b list` | 对每个元素应用函数 |
| `List.rev` | `'a list -> 'a list` | 反转列表 |
| `List.iter` | `('a -> unit) -> 'a list -> unit` | 对每个元素执行副作用（如打印） |
| `List.fold_left` | `('a -> 'b -> 'a) -> 'a -> 'b list -> 'a` | 左折叠，带累加器（尾递归友好） |
| `List.fold_right` | `('a -> 'b -> 'b) -> 'a list -> 'b -> 'b` | 右折叠（非尾递归） |
| `List.length` | `'a list -> int` | 列表长度 |
| `List.nth` | `'a list -> int -> 'a` | 取第 i 个（O(i)，慢） |
| `List.append` / `@` | `'a list -> 'a list -> 'a list` | 拼接（`@` 是中缀写法） |
| `List.filter` | `('a -> bool) -> 'a list -> 'a list` | 按谓词过滤 |
| `List.find_opt` | `('a -> bool) -> 'a list -> 'a option` | 找第一个满足的，返回 option |
| `List.assoc_opt` | `'a -> ('a * 'b) list -> 'b option` | 在关联列表里按键查找 |
| `List.mem` | `'a -> 'a list -> bool` | 是否包含某元素 |
| `List.sort` | `('a -> 'a -> int) -> 'a list -> 'a list` | 排序（`compare` 是内置比较） |
| `List.sort_uniq` | `('a -> 'a -> int) -> 'a list -> 'a list` | 排序并去重 |

**调用示例**（注释是返回值）：

```ocaml
(* ---- 转换 / 遍历 ---- *)
List.map (fun x -> x * 2) [1; 2; 3]              (* [2; 4; 6] *)
List.map string_of_int [1; 2; 3]                  (* ["1"; "2"; "3"] *)
List.iter (fun x -> print_int x) [1; 2; 3]        (* 打印 123，返回 () *)
List.filter (fun x -> x mod 2 = 0) [1; 2; 3; 4]   (* [2; 4] *)
List.rev [1; 2; 3]                                (* [3; 2; 1] *)

(* ---- 折叠（带累加器） ---- *)
(* fold_left：从左往右，尾递归友好。f 接 acc 再接 element *)
List.fold_left (fun acc x -> acc + x) 0 [1; 2; 3; 4]   (* 10，求和 *)
List.fold_left (fun acc x -> x :: acc) [] [1; 2; 3]    (* [3; 2; 1]，等价 rev *)
(* fold_right：从右往左，非尾递归。f 接 element 再接 acc *)
List.fold_right (fun x acc -> x + acc) [1; 2; 3; 4] 0  (* 10 *)

(* ---- 查找 / 长度 ---- *)
List.length [1; 2; 3]                             (* 3 *)
List.nth [10; 20; 30] 1                           (* 20，O(i) 慢操作 *)
List.find_opt (fun x -> x > 1) [1; 2; 3]          (* Some 2 *)
List.assoc_opt "x" [("x", 1); ("y", 2)]           (* Some 1，关联列表按键找 *)
List.mem 2 [1; 2; 3]                              (* true，是否包含 *)

(* ---- 拼接 / 头插 ---- *)
List.append [1; 2] [3; 4]                         (* [1; 2; 3; 4] *)
[1; 2] @ [3; 4]                                   (* 同上，中缀写法 *)
0 :: [1; 2]                                       (* [0; 1; 2]，头插 O(1) *)

(* ---- 排序 / 去重（偶尔用） ---- *)
List.sort compare [3; 1; 2]                       (* [1; 2; 3] *)
List.sort_uniq compare [1; 1; 2]                  (* [1; 2] *)
```

**关键模式：递归 + 头插 + `List.rev`**

```ocaml
(* 边收集边头插（O(1)），最后反转（O(n)），总 O(n) *)
let rec aux acc = ... aux (x :: acc) ...
in List.rev acc
```
你的 `tokenize` 作业就是这个模式。**不要用 `acc @ [x]` 尾插**，那是 O(n²)。

### 10.2 String 模块（字符串操作）

| 函数 | 类型 | 作用 |
|---|---|---|
| `String.length` | `string -> int` | 字符串长度 |
| `String.get` / `s.[i]` | `string -> int -> char` | 取第 i 个字符（`s.[i]` 是中缀写法） |
| `String.sub` | `string -> int -> int -> string` | 取子串（**起始位置 + 长度**，不是起止） |
| `String.concat` | `string -> string list -> string` | 用分隔符拼接字符串列表 |
| `String.make` | `int -> char -> string` | 造长度 n 的字符串，全填某字符 |
| `String.uppercase_ascii` | `string -> string` | 转大写 |
| `String.lowercase_ascii` | `string -> string` | 转小写 |
| `String.equal` | `string -> string -> bool` | 显式相等比较 |
| `String.to_seq` | `string -> char Seq.t` | 转成字符惰性序列 |
| `String.iter` | `(char -> unit) -> string -> unit` | 遍历每个字符执行副作用 |

**调用示例**：

```ocaml
(* ---- 取 / 设 ---- *)
String.length "hello"                  (* 5 *)
String.get "hello" 0                   (* 'h'，等价 "hello".[0] *)
"hello".[1]                            (* 'e'，中缀写法 *)

(* ---- 子串（注意：参数是 起始位置 + 长度，不是起止） ---- *)
String.sub "hello world" 6 5           (* "world"，从位置6取5个字符 *)
String.sub "abc" 0 2                   (* "ab" *)

(* ---- 拼接 / 造串 ---- *)
String.concat ", " ["a"; "b"; "c"]     (* "a, b, c"，第一个参数是分隔符 *)
String.concat "" ["a"; "b"; "c"]       (* "abc"，空分隔 = 直连 *)
String.make 3 'x'                      (* "xxx"，造长度3全填 x *)
String.make 1 'x'                      (* "x"，char→string 常用技巧 *)
"a" ^ "b"                              (* "ab"，中缀拼接，不用 String.concat *)

(* ---- 大小写 / 比较 ---- *)
String.uppercase_ascii "abc"           (* "ABC" *)
String.lowercase_ascii "ABC"           (* "abc" *)
String.equal "abc" "abc"               (* true，显式相等 *)

(* ---- 遍历 ---- *)
String.to_seq "abc"                    (* char Seq.t，惰性序列 *)
String.iter (fun c -> print_char c) "abc"   (* 打印 abc *)
```

陷阱：`String.sub` 参数是**起始 + 长度**，不是"起止下标"。`String.sub "hello" 1 3` = `"ell"`（从位置1取3个），不是 `"el"`。

### 10.3 其他常用模块

| 函数 | 类型 | 作用 |
|---|---|---|
| `string_of_int` | `int -> string` | int 转 string（顶层函数） |
| `int_of_string` | `string -> int` | string 转 int（解析失败抛 `Failure`） |
| `string_of_float` / `float_of_string` | 互转 | float 版本 |
| `Char.code` | `char -> int` | char 转 ASCII 码 |
| `Char.chr` | `int -> char` | ASCII 码转 char |
| `Printf.printf` | `('a, out_channel, unit) format -> 'a` | 格式化打印 |
| `print_endline` | `string -> unit` | 打印字符串 + 换行 |
| `print_int` | `int -> unit` | 打印 int（无换行） |
| `print_char` | `char -> unit` | 打印 char |
| `failwith` | `string -> 'a` | 抛 `Failure` 异常 |

**调用示例**：

```ocaml
(* ---- int / string / float 互转（顶层函数，不在模块里） ---- *)
string_of_int 42                       (* "42" *)
int_of_string "42"                     (* 42，解析失败抛 Failure *)
string_of_float 3.14                   (* "3.14" *)
float_of_string "3.14"                 (* 3.14 *)

(* ---- char 与 ASCII ---- *)
Char.code 'A'                          (* 65，char → ASCII *)
Char.chr 65                            (* 'A'，ASCII → char *)
'A' <= c && c <= 'Z'                   (* 判断大写字母 *)

(* ---- 打印 ---- *)
print_endline "hi"                     (* 打印 hi\n，返回 () *)
print_int 42                           (* 打印 42，无换行 *)
print_char 'x'                         (* 打印 x *)
Printf.printf "%d = %s\n" 42 "answer"  (* 打印 42 = answer\n *)
(* 格式符：%d int  %s string  %c char  %f float  %b bool  %a 自定义 *)

(* ---- 异常 ---- *)
failwith "something went wrong"        (* 抛 Failure 异常，类型 'a（任意） *)
raise (Failure "msg")                  (* 等价 failwith，但 raise 要 exn 类型 *)
```

### 10.4 常见管道组合模式

```ocaml
(* 模式 1：map 后拼接成字符串 *)
[1; 2; 3]
|> List.map string_of_int
|> String.concat "; "
|> Printf.printf "[%s]\n"
(* 输出 [1; 2; 3] *)

(* 模式 2：fold_left 累计 *)
[1; 2; 3; 4]
|> List.fold_left (fun acc x -> acc + x) 0
|> print_int

(* 模式 3：filter + map *)
[1; 2; 3; 4; 5]
|> List.filter (fun x -> x mod 2 = 0)
|> List.map (fun x -> x * x)
(* [4; 16]，先过滤偶数再平方 *)
```

### 10.5 数据结构选择指南（List / Array / Queue / Stack / Hashtbl / Map）

OCaml 标准库提供多种集合，选错会 O(n²) 或栈溢出。按"要做什么操作"来选。

#### 一览表（按场景选）

| 结构 | 底层 | 可变性 | 头部操作 | 尾部操作 | 随机访问 | 键值查找 | 何时用 |
|---|---|---|---|---|---|---|---|
| `list` | 单向链表 | **不可变** | O(1) `::` | O(n) `lst @ [x]` | O(n) | — | AST、token 流、递归遍历主力 |
| `array` | 连续内存数组 | **可变** | O(n) | O(1) 摊销 | O(1) `a.(i)` | — | 缓冲区、查表、需要索引访问 |
| `Bytes` | 可变字节序列 | **可变** | O(n) | O(1) 摊销 | O(1) `b.[i]` | — | 二进制数据、字符缓冲 |
| `Queue` | 双端链表 | **可变** | O(1) 入队 | O(1) 出队 | 不支持 | — | FIFO 队列、广度优先 |
| `Stack` | 可变链表 | **可变** | O(1) push | O(1) pop | 不支持 | — | LIFO 栈、深度优先、待处理列表 |
| `Hashtbl` | 哈希表 | **可变** | — | — | — | O(1) 均摊 | 符号表、缓存、大键值 |
| `Map`（`Map.Make`） | 平衡树 | **不可变** | — | — | — | O(log n) | 小键值、需要有序/不可变快照 |
| `Set`（`Set.Make`） | 平衡树 | **不可变** | — | — | — | O(log n) | 集合运算（并/交/差） |
| `Seq` | 惰性流 | 惰性 | 惰性 | 惰性 | 不支持 | — | 流式读大文件、无穷序列 |

#### list（不可变单向链表）

最常用，详见 §10.1。要点：头部 O(1)、尾部 O(n)、不可变（改一次复制一份）。递归 + 头插 + `List.rev` 是经典模式。**不支持 O(1) 随机访问**——`List.nth lst i` 是 O(i)。需要按下标取用换 `array`。

```ocaml
let l = [1; 2; 3]
let l2 = 0 :: l          (* [0; 1; 2; 3]，O(1)，原 l 不变 *)
let l3 = l @ [4]         (* [1; 2; 3; 4]，O(n)，复制左整条 *)
let _ = List.nth l 1     (* 2，但 O(1) 这里只是因为短，本质 O(i) *)
```

#### array（可变数组）

连续内存，**可变**，O(1) 随机访问 `a.(i)`。长度固定（不能动态追加，要改长度用 `Bytes` 或自己管理）。

常用函数：

| 函数 | 作用 |
|---|---|
| `Array.make n x` | 造长度 n 的数组，全填 x |
| `Array.get a i` / `a.(i)` | 取第 i 个 |
| `Array.set a i x` / `a.(i) <- x` | 设第 i 个（**可变**） |
| `Array.length a` | 长度 |
| `Array.init n f` | 用 `f 0; f 1; ...` 初始化 |
| `Array.map f a` | 对每个元素应用 f，返回新数组 |
| `Array.iter f a` | 遍历执行副作用 |
| `Array.to_list` / `Array.of_list` | array ↔ list 互转 |

```ocaml
let a = Array.make 5 0          (* [|0; 0; 0; 0; 0|] *)
let () = a.(0) <- 42            (* 可变修改：[|42; 0; 0; 0; 0|] *)
let l = Array.to_list a         (* 转成 list：[42; 0; 0; 0; 0] *)
let a2 = Array.init 3 (fun i -> i * i)   (* [|0; 1; 4|] *)
```

写编译器用途：存符号表条目（按下标查）、字符缓冲（配合 `Bytes`）、预分配大小的缓存。

#### Queue（可变 FIFO 队列）

两端都 O(1)：`push`（入队）、`pop`（出队）。**可变**，不返回新队列。

| 函数 | 作用 |
|---|---|
| `Queue.create ()` | 建空队列 |
| `Queue.push x q` | 入队尾，O(1) |
| `Queue.pop q` | 出队头，O(1)，队列空抛 `Queue.Empty` |
| `Queue.peek q` | 看队头不出队 |
| `Queue.is_empty q` | 是否空 |
| `Queue.length q` | 长度 |
| `Queue.iter f q` | 遍历 |

```ocaml
let q = Queue.create ()
let () = Queue.push 1 q
let () = Queue.push 2 q
let _ = Queue.pop q     (* 1，FIFO：先入先出 *)
let _ = Queue.pop q     (* 2 *)
```

写编译器用途：广度优先遍历 AST、工作列表（待处理任务队列）、token 缓冲。

#### Stack（可变 LIFO 栈）

两端都 O(1)：`push`（压栈）、`pop`（弹栈）。**可变**。

| 函数 | 作用 |
|---|---|
| `Stack.create ()` | 建空栈 |
| `Stack.push x s` | 压栈顶，O(1) |
| `Stack.pop s` | 弹栈顶，O(1)，栈空抛 `Stack.Empty` |
| `Stack.top s` | 看栈顶不弹出 |
| `Stack.is_empty s` | 是否空 |

```ocaml
let s = Stack.create ()
let () = Stack.push 1 s
let () = Stack.push 2 s
let _ = Stack.pop s     (* 2，LIFO：后入先出 *)
let _ = Stack.pop s     (* 1 *)
```

写编译器用途：括号匹配、表达式求值的操作数栈、深度优先遍历的待处理节点、作用域栈（进入函数压栈、退出弹栈）。

#### Hashtbl（可变哈希表，键值存储）

**可变**，O(1) 均摊查找。写编译器的符号表主力。

| 函数 | 作用 |
|---|---|
| `Hashtbl.create n` | 建表，n 是初始桶数 |
| `Hashtbl.add h k v` | 加键值对（允许重复键） |
| `Hashtbl.find h k` | 找键的值，找不到抛 `Not_found` |
| `Hashtbl.find_opt h k` | 找键，返回 `v option`（推荐，不抛异常） |
| `Hashtbl.replace h k v` | 设键值（覆盖现有键） |
| `Hashtbl.remove h k` | 删键 |
| `Hashtbl.mem h k` | 是否存在该键 |

```ocaml
let h = Hashtbl.create 16
let () = Hashtbl.replace h "x" 1
let v = Hashtbl.find_opt h "x"   (* Some 1 *)
let v2 = Hashtbl.find_opt h "y"  (* None *)
```

写编译器用途：变量名 → 类型/值的符号表、字符串内化（interning）、缓存。

#### Map（不可变平衡树，有序键值）

**不可变**，O(log n) 查找。需要先 `Map.Make(Key)` 模块化（Key 要支持比较）。

```ocaml
module StringMap = Map.Make(String)   (* 以 string 为键的 Map *)
let m = StringMap.empty
let m = StringMap.add "x" 1 m          (* 返回新 Map，原 m 不变 *)
let v = StringMap.find_opt "x" m       (* Some 1 *)
```

何时用 Map 而非 Hashtbl：
- 需要**不可变快照**（多版本符号表，回溯）
- 需要**按序遍历**键
- 键少（哈希表有固定开销）
- 想要纯函数式（测试友好）

写编译器用途：纯函数式类型环境（作用域回溯快）、有序符号表。

#### Set（不可变平衡树集合）

类似 `Map` 但只存键（无值）。`Set.Make(Elem)` 模块化。

```ocaml
module StringSet = Set.Make(String)
let s = StringSet.empty
let s = StringSet.add "x" s
let s2 = StringSet.union s (StringSet.singleton "y")  (* 并集 *)
```

写编译器用途：活变量集合（数据流分析）、自由变量集合、已访问节点集合。

#### Seq（惰性序列）

不立即计算，要一个产一个。适合流式处理大文件、无穷流（如斐波那契）。

```ocaml
let naturals = Seq.init (fun i -> i)   (* 无穷自然数序列 *)
naturals
|> Seq.take 5                          (* 只取前5个：[0;1;2;3;4] *)
|> List.of_seq                          (* 转成 list 才能打印 *)
```

写编译器用途：按需读 token 流、大文件分块处理。日常小数据用 list 即可。

#### 速记口诀

- **不可变 + 递归遍历** → `list`
- **O(1) 随机访问 / 可变缓冲** → `array`（或 `Bytes` 存字节）
- **FIFO 工作列表** → `Queue`
- **LIFO 栈** → `Stack`
- **符号表 / 缓存（可变）** → `Hashtbl`
- **符号表 / 有序 / 不可变快照** → `Map`
- **集合运算** → `Set`
- **流式 / 大数据惰性** → `Seq`

> 写编译器最常用：`list`（AST/遍历）、`Hashtbl` 或 `Map`（符号表）、`Stack`（作用域/求值栈）。`Array` 用于需要索引的查表。

---

## 10.6 编译器工具：ocamllex + menhir

写编译器前端（lexer + parser）的两个标准工具。**都不是 OCaml 语言的一部分**，是独立的工具，dune 自动集成。它们用的指令（`%` 开头）和 OCaml 关键字是两回事。

### 三个层次要分清

| 层次 | 例子 | 在哪里 |
|---|---|---|
| **OCaml 关键字** | `let` `rec` `match` `type` `fun` | `.ml` 文件，语言保留字 |
| **工具指令** | `%token` `%left` `%prec` `rule` | `.mly` / `.mll` 文件，工具解析 |
| **OCaml 代码** | `Add (e1, e2)`、`open Tokens` | `.mly` 的 `%{ %}` 头部和 `{ }` 动作里 |

---

### ocamllex（词法分析生成器）

**作用**：你写 `.mll` 规则文件，ocamllex 生成一个 `.ml`，提供"吃字符流吐 token"的 lexer 函数。代替手写 `tokenize`。

#### `.mll` 文件结构

```ocaml
{
(* 头部：OCaml 代码，open 模块、定义辅助函数 *)
open Tokens
}

rule token = parse
  | ['0'-'9']+      { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | '+'             { PLUS }
  | '-'             { MINUS }
  | '*'             { STAR }
  | '/'             { SLASH }
  | '('             { LPAREN }
  | ')'             { RPAREN }
  | [' ' '\t'\n']+  { token lexbuf }      (* 跳过空白，递归继续 *)
  | eof             { EOF }
  | _ as c          { failwith (Printf.sprintf "unexpected char %c" c) }

{
(* 尾部：可选 OCaml 代码 *)
}
```

#### 逐段解释

- `{ ... }` 头部/尾部 —— 普通 OCaml 代码块，通常 `open Tokens`
- `rule token = parse` —— `rule`/`parse` 是 ocamllex 指令，定义一个叫 `token` 的 lexer 入口（`token` 是自己起的名）
- `| 正则 { 动作 }` —— 每条规则：左边正则模式，右边匹配到时执行的 OCaml 代码（返回 token）
- `lexbuf` —— 隐式可用的词法缓冲区变量（不用声明，ocamllex 注入）
- `Lexing.lexeme lexbuf` —— 取这次匹配到的字符串
- `eof` —— 特殊模式，输入结束

#### 正则语法（ocamllex 用 POSIX 风格）

| 正则 | 含义 |
|---|---|
| `'a'` | 字面字符 a |
| `['0'-'9']` | 字符集：0 到 9 |
| `['a'-'z' 'A'-'Z']` | 字母集（含空格分隔） |
| `['0'-'9']+` | 一个或多个数字（`+` 重复） |
| `['0'-'9']*` | 零或多个（`*`） |
| `('a' \| 'b')+` | 分组 + 或 |
| `[^'a']` | 非 a 的任意字符 |
| `eof` | 输入结束（特殊） |

#### 怎么用

```ocaml
let lexbuf = Lexing.from_string "1 + 2"    (* string → lexbuf *)
let t1 = token lexbuf       (* INT 1 *)
let t2 = token lexbuf       (* PLUS *)
let t3 = token lexbuf       (* INT 2 *)
let t4 = token lexbuf       (* EOF *)
```

每次调 `token lexbuf` 读一个 token 并推进位置。`Lexing.from_string` 把字符串包装成 lexbuf。

#### dune 集成

dune 自动识别 `.mll`，调 ocamllex 编译成 `.ml`。不用手动跑命令。`.mll` 和 `.ml` 放同目录，dune 自动处理依赖。

---

### menhir（语法分析生成器）

**作用**：你写 `.mly` 文法文件，menhir 生成一个 `.ml` + `.mli`，提供 parser 函数。代替手写递归下降。比 ocamlyacc 现代化（更好的错误信息、LR(1) 而非 LALR）。

#### `.mly` 文件结构

```ocaml
%{
  (* 头部：OCaml 代码 *)
  open Tokens
%}

(* 声明段：token、优先级、起点 *)
%token <int> INT            (* 带值 token：<int> 是携带类型 *)
%token PLUS MINUS STAR SLASH   (* 无值 token *)
%token LPAREN RPAREN
%token EOF

%start <expr> main         (* 起点规则 main，返回 expr *)

%left PLUS MINUS           (* 优先级低，左结合 *)
%left STAR SLASH           (* 优先级高，左结合 *)
%precedence NEG            (* 最高优先级，伪 token（无结合性）*)

%%

(* 规则段 *)
main:
  | e = expr EOF { e }

expr:
  | e1 = expr PLUS  e2 = expr { Add (e1, e2) }
  | e1 = expr MINUS e2 = expr { Sub (e1, e2) }
  | e1 = expr STAR  e2 = expr { Mul (e1, e2) }
  | e1 = expr SLASH e2 = expr { Div (e1, e2) }
  | MINUS e = expr %prec NEG { Neg (e) }
  | n = INT                  { Num n }
  | LPAREN e = expr RPAREN   { e }

%%
```

#### menhir 指令清单

| 指令 | 作用 | 例 |
|---|---|---|
| `%{ ... %}` | 头部 OCaml 代码块 | `open Tokens` |
| `%% ... %%` | 规则段分隔（两个 `%%` 之间是文法） | — |
| `%token` | 声明无值 token | `%token PLUS MINUS` |
| `%token <T>` | 声明带值 token（携带类型 `T`） | `%token <int> INT` |
| `%start <T> name` | 声明起点规则 `name`，返回类型 `T` | `%start <expr> main` |
| `%left` | 声明左结合优先级（从低到高排） | `%left PLUS MINUS` |
| `%right` | 声明右结合优先级 | `%right ASSIGN`（赋值右结合） |
| `%precedence` | 声明优先级但不指定结合性（给伪 token） | `%precedence NEG` |
| `%prec TOKEN` | 给单条规则指定优先级层次（在规则后） | `MINUS e = expr %prec NEG` |
| `%nonassoc` | 声明无结合性（禁连续，如比较运算） | `%nonassoc EQ NEQ` |

> 所有 `%` 开头的都是**指令**，不是 OCaml 关键字。它们只出现在 `.mly` 里。

#### 规则语法

```
非终结符:
  | 模式 { 动作 }
  | 模式 { 动作 }
```

- `e1 = expr` —— 匹配 `expr`，绑定到名字 `e1`（`= 名字` 是绑定语法）
- `PLUS` —— 字面 token（直接写 token 名，不绑定）
- `{ Add (e1, e2) }` —— 动作：用绑定的名字构造 AST 节点

#### 优先级怎么自动生效

手写时要靠三层函数编码优先级。menhir 里**所有 `expr` 规则写一起**，靠 `%left` 声明自动解决冲突：

- `1 + 2 * 3`：`*` 优先级高于 `+`（`%left STAR` 在 `%left PLUS` 后），先组合 `2*3` ✅
- `1 - 2 - 3`：`%left MINUS` 左结合，先组合 `(1-2)` ✅

#### `%prec NEG` 解决一元/二元冲突

`MINUS` token 在两种规则出现：

```
二元减法：expr MINUS expr     ← 低优先级（%left MINUS 那层）
一元负号：MINUS expr           ← 要高优先级（否则 -5*3 解析错）
```

`%precedence NEG` 声明最高层 → `MINUS e = expr %prec NEG` 把一元规则挂到最高层 → `-5 * 3` = `Mul (Neg (Num 5), Num 3)` = `(-5)*3` ✅

#### dune 集成

dune 自动识别 `.mly`，调 menhir 编译。`.mly` 和主程序 `.ml` 放同目录。生成的模块名 = 文件名首字母大写（`parser.mly` → `Parser` 模块）。

主程序调用：

```ocaml
let parse input =
  let tokens = tokenize input in          (* 自己的 lexer，或 ocamllex 生成 *)
  let pos = ref tokens in
  let next_token () =
    match !pos with
    | [] -> EOF
    | t :: rest -> pos := rest; t
  in
  Parser.main next_token                 (* menhir 生成的 Parser 模块 *)
```

`Parser.main` 通常接受一个 `unit -> token` 读取器函数。确切签名看 dune 生成的 `_build/default/.../parser.mli`。

---

### 手写 vs 工具：何时用哪个

| | 手写递归下降 | ocamllex + menhir |
|---|---|---|
| 学习价值 | 高（理解原理） | 实用（理解工具） |
| 代码量 | 多 | 少 |
| 优先级/结合性 | 靠函数结构编码 | 声明式 `%left` |
| 错误信息 | 自己写 | 自动带位置 |
| 维护 | 改文法要重写 | 改 `.mly` 一处 |
| 工业级 | 少用 | 主流（OCaml/Rust/Coq 都用） |

> 建议：手写一遍理解原理，之后用 menhir 提效。本课程的 calc2/calc3 是手写版，calc4 是 menhir 版。

---

## 11. 可变性（命令式特性，了解即可）

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

## 12. 模块（简述）

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

## 13. 注释

```ocaml
(* 单行注释 *)

(*
  多行注释
  (* 可以嵌套！这是 OCaml 特色 *)
*)
```

`(*` `*)` 是注释符号，**可嵌套**（C/Java 的 `/* */` 不能嵌套）。

---

## 14. 运行一个程序

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

**dune 是 OCaml 的构建系统**，类似 make/cmake/cargo。负责编译、管多文件多模块依赖、增量编译、链接第三方库。`ocaml x.ml` 是玩具写法，写编译器必须用 dune。

#### 最小工程结构

```
hello_ocaml/
├── dune-project      ← 项目级声明（整个仓库一个）
├── dune              ← 当前目录的构建规则（每个目录一个）
└── hello.ml
```

两个文件都**无扩展名**，分别叫 `dune-project` 和 `dune`（全小写）。

#### `dune-project` 内容

```lisp
(lang dune 3.0)
```

Lisp 风格语法（括号 + 关键字）。`3.0` 是 dune 语法的版本号，写 `3.0` 是当前主流。

#### `dune` 文件内容

```lisp
(executable
 (name hello))
```

- `(executable ...)` —— 构建一个可执行文件（不是库）
- `(name hello)` —— 入口源码是 `hello.ml`（填**不带 `.ml`** 的根名）

#### `(name X)` 必须和源码文件名对应（硬规则）

```
(name calc)  →  找 calc.ml  →  产物 calc.exe
(name hello) →  找 hello.ml →  产物 hello.exe
```

名字和文件名是**硬绑定**：写 `(name calc)` 但只有 `main.ml` → 报 `Missing file calc.ml`。三者（dune 里的 name、源码文件、产物）共享同一个根名。

#### 常用命令

```bash
dune exec ./hello.exe       # 编译并立即运行（最常用）
dune build                  # 只编译，不运行
dune clean                  # 清理 _build 目录
dune runtest                # 跑测试（配了测试的话）
```

#### `.exe` 后缀的约定（不是 Linux 要求）

dune 跨平台，Windows 可执行文件必须 `.exe`，所以 dune 统一规定产物都叫 `名字.exe`，**Linux 上也加**。`hello.exe` 实际是普通 Linux ELF 文件，只是名字带 `.exe`。

`dune exec` 按产物名**精确查找**，必须带 `.exe`：

```bash
dune exec ./hello.exe    # ✅
dune exec ./hello        # ❌ Program not found
```

也可以直接执行产物（绕开 dune 命名，含 `/` 即按路径执行）：
```bash
_build/default/hello.exe     # ✅ 直接跑产物
```

#### dune 默认把警告当错误

dune 的工程哲学：警告就该修。所以警告会升级为错误导致编译失败。例：

```
Error (warning 37 [unused-constructor]): constructor Sub is never used to build values.
```

这是**好事**——逼你保持代码干净。若确需关闭（不推荐），在 `dune` 里加：

```lisp
(executable
 (name calc)
 (flags :standard -warn-error -a))      ; 警告不再升级为错误
```

#### 多目录项目结构

```
self-made-compiler/
├── dune-project          ← 项目根（整个仓库一个）
├── hello_ocaml/
│   ├── dune              ← (executable (name hello))
│   └── hello.ml
└── calc/
    ├── dune              ← (executable (name calc))
    └── calc.ml
```

每个子目录一个 `dune`，各管各的；`dune-project` 整个仓库只要一个在根。在仓库根敲：

```bash
dune exec ./calc/calc.exe       # 跑指定那个
```

#### 引用第三方库

在 `dune` 里声明 `(libraries ...)`：

```lisp
(executable
 (name calc)
 (libraries str))              ← 引用 str 库
```

`dune build` 自动链接，不用手动 `ocamlfind ocamlopt -package str ...`。

#### 接口文件 `.mli`（可选）

`.ml` 是实现，`.mli` 是接口（声明对外暴露什么）。有 `.mli` 时 dune **强制实现匹配接口**——多一个少一个都报错：

```
Error: The value `hello' is required but not provided
```

`.mli` 的价值是**信息隐藏**（不声明的 = 外部不可见）。练基础时可先删掉 `.mli`，学到模块系统再正式用。

#### `ocaml` 脚本模式 vs `dune` 编译模式的差异

| | `ocaml hello.ml` | `dune exec ./hello.exe` |
|---|---|---|
| 模式 | 脚本解释执行 | 先**全文件类型检查**，通过后才编译运行 |
| 顺序 | 顶层绑定从上到下逐个求值 | 整个文件一起类型检查 |
| 部分报错 | 前面的副作用可能先执行，后面才报错 | 类型检查阶段就拦住，不执行任何代码 |

写编译器时以 `dune` 的"全文件类型检查"为准——它更接近真实编译器行为。

---

## 15. 速记口诀

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
- **dune**：`(name X)` 必须对应 `X.ml`；产物 `X.exe`（`.exe` 是 dune 跨平台约定，Linux 也加）；`dune exec ./X.exe` 运行；警告默认当错误
- **标准库**：`List.map` 转换、`List.fold_left` 累积、`List.rev` 反转、`List.iter` 副作用遍历；`String.sub` 取子串、`String.concat` 拼接；递归 + 头插 + `List.rev` 是列表处理经典模式
- **编译器工具**：`.mll` 用 ocamllex（`rule ... parse` + 正则），`.mly` 用 menhir（`%token`/`%left`/`%prec`）；dune 自动识别编译；`%` 开头都是工具指令不是 OCaml 关键字

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
