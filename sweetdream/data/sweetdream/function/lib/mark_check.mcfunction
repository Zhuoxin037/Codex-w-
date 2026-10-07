# ============================================================
# sweetdream:lib/mark_check —— 消耗第 ① 步: 目标身上真有这个标签吗
# ------------------------------------------------------------
# 【宏参数】zx:work mc {target, mark, by}（由 lib/mark_consume 冻结好）
# 【为什么单独一个文件】"有没有某个标签"只能写成 `@s[tag=zx.status.$(mark)]`，
#   带 $( ) 的行必须在宏函数里；而入口 mark_consume 是非宏（调用点不带参数）。
# 【★ 不能拼双括号选择器 ★】写成 `if entity $(target)[tag=zx.status.$(mark)]`
#   会展开成 `@e[tag=a][tag=b]` = 语法错误、整个函数作废（见 RULES 坑 44）。
#   必须 `as $(target)` 再 `if entity @s[...]`。
# 【判完 @s 自动回到调用者】下一行不写 as 就还是原执行者。
# ============================================================

data modify storage zx:work mc.ok set value 0b
$execute as $(target) if entity @s[tag=zx.status.$(mark)] run data modify storage zx:work mc.ok set value 1b
$execute if data storage zx:work mc{ok:1b} run function sweetdream:lib/mark_take {target:"$(target)",mark:"$(mark)",by:"$(by)"}
