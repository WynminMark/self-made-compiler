# 学习进度

## 第一课：OCaml 基础（2026-08-24）✅ 完成

- 学了：标识符大小写规则、关键字、`let`/`let rec`、函数、内置类型、ADT（变体/记录）、模式匹配、`option`、`|>` 管道
- 作业：[hello_ocaml/hello.ml](../hello_ocaml/hello.ml) —— `greet` + `greeting` ADT + `render` 模式匹配 + `|>` 打印。批改 A-，功能正确，风格可改进（`let ()` 入口、避免遮蔽、提取重复）
- 速查文档：[ocaml-basics.md](ocaml-basics.md)

## 第二课 TODO（明天）

### 任务 1：搭 dune 工程（先把 hello_ocaml 升级）

把 `hello_ocaml/` 从 `ocaml hello.ml` 直跑，升级成 dune 项目结构。需要新建：

```
hello_ocaml/
├── dune-project      # 内容：(lang dune 3.0)
└── dune              # 内容：
                      #   (executable
                      #    (name hello))
```

建好后用 `dune exec ./hello.exe` 运行，代替 `ocaml hello.ml`。
这是后面写编译器（多文件、多模块）的基础设施，趁早搭好。

### 任务 2：迷你计算器（AST + 递归求值器）

这是写编译器 AST 解释器的雏形。在 `hello_ocaml/` 同级建 `calc/`，用 dune。

**要求：**

1. 定义表达式 ADT（带嵌套递归）：
   ```ocaml
   type expr =
     | Num of int
     | Add of expr * expr
     | Sub of expr * expr
     | Mul of expr * expr
     | Div of expr * expr
   ```

2. 写递归求值器 `eval : expr -> int`，用模式匹配 + `let rec`。注意：
   - 除法除零怎么办？（提示：`raise` 一个异常，或返回 `int option`）
   - 编译器必须无警告（穷尽性）

3. 构造几个测试表达式（不用读输入，直接写死）：
   ```ocaml
   let e = Add (Num 1, Mul (Num 2, Num 3))   (* 1 + 2*3 = 7 *)
   ```

4. `let () =` 入口打印 `eval` 结果（`print_int` + `print_endline`，或 `Printf.printf "%d\n"`）。

**验收：**
- `dune exec` 成功运行，输出正确结果
- 编译无警告
- 能解释递归和模式匹配每一步
- 思考题：如果要让表达式能从字符串解析（如 `"1+2*3"`）该怎么扩展？（这其实就是 lexer + parser 的雏形，后面课程会讲）

### 选做（有余力再看）

5. 加一个 `Neg of expr`（一元负号）构造子，观察 dune 重新编译时哪些 `match` 报穷尽性警告——体会 OCaml 写编译器的全局影响分析红利。

---

> 进度记录格式：完成一课就标 ✅，新课写 TODO。日期用绝对日期。
