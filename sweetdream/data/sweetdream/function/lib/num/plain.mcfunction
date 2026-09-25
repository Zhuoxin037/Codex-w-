# ============================================================
# sweetdream:lib/num/plain —— 双精度 -> 能直接塞进命令的"纯数字字符串"
# ------------------------------------------------------------
# 【为什么需要它】命令的数值参数只能是写在命令文本里的字面量, 没法直接
#   引用 NBT 路径。所以想把存储里的值用进 /damage、/effect、/attribute
#   这类命令, 必须走"宏变量拼字符串"这条路。
# 【问题】宏渲染时 DoubleTag 会变成 "37.5d"、FloatTag 会变成 "37.5f",
#   末尾那个字母是 NBT 的类型标记, 不是数字的一部分, 命令解析器不认。
# 【怎么办】把渲染结果存成字符串, 判断最后一个字符是不是类型后缀,
#   是就砍掉。判断而不是无脑砍, 是为了不依赖"某个版本一定带后缀"。
# 【输入】sweetdream:work a.num        【输出】sweetdream:work a.num_str
# 【用法】
#     data modify storage zx:work a.num set from storage <某个 double 路径>
#     function sweetdream:lib/num/plain
#     之后 sweetdream:work a.num_str 就是 "37.5" 这样的纯数字字符串
# ============================================================

execute unless data storage zx:work a.num run data modify storage zx:work a.num set value 0.0

# 强制转成 double: 不管传进来的是 int / float / string, 都先归一化,
# 这样后面"有没有后缀字符"这件事才是有意义的。
execute store result storage zx:work a.num double 1 run data get storage zx:work a.num

function sweetdream:lib/num/plain_go with storage zx:work a
