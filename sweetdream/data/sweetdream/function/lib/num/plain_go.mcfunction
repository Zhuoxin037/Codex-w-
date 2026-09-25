# ============================================================
# sweetdream:lib/num/plain_go —— 宏实现部分(被 lib/num/plain 调用)
# ------------------------------------------------------------
# 【宏参数】sweetdream:work a {num}
# 【第 ① 步】宏渲染 -> raw = "37.5d"(带后缀)
# 【第 ② 步】先无脑后缀地原样存一份当兜底
# 【第 ③ 步】取 raw 的最后一个字符
# 【第 ④ ⑤ 步】只有最后一位确实是 d / f 时才砍掉它
#   —— 这样无论你那个版本的宏渲染带不带后缀, 结果都是正确的 "37.5"
# 【set string 的用法】data modify ... set string <来源> <起点> [<终点>]
#   负数表示从末尾往前数: -1 = 最后一个字符。
#   "0 -1" = 从第 0 个取到倒数第一个之前, 也就是砍掉末尾一个字符。
# 【注意】num 这个键必须存在, 否则第 ① 行的宏展开会让整个函数调用失败。
#   用 lib/num/plain 入口调用就不会有这个问题。
# 【注意 2】只有含 $(变量) 的行才能加 $ 前缀。加了 $ 却不带变量, 加载时会直接
#   报 "Macro without variables" 并且整个函数作废 —— 下面第 ③④⑤ 行都因此
#   不能带 $, 它们只是普通命令。
# ============================================================

$data modify storage zx:work a.raw set value "$(num)"
$data modify storage zx:work a.num_str set value "$(num)"
data modify storage zx:work a.last set string storage zx:work a.raw -1

execute if data storage zx:work a{last:"d"} run data modify storage zx:work a.num_str set string storage zx:work a.raw 0 -1
execute if data storage zx:work a{last:"f"} run data modify storage zx:work a.num_str set string storage zx:work a.raw 0 -1
