# ------------------------------------------------------------
# internal/fmt/plain —— 去掉数字后缀的宏实现(被 lib/num/plain 调用)
# 【宏参数】manacore:work.a {num}
# 【第 1 行】宏渲染: DoubleTag 会被渲染成 "12.5d"(带 NBT 类型后缀)
# 【第 2 行】先原样存一份当兜底
# 【第 3 行】取 raw 的最后一个字符
# 【第 4/5 行】只有最后一位确实是 d / f 时才用 set string 0 -1 砍掉它
#   —— set string <来源> <起点> [<终点>], 负数表示从末尾往前数,
#      "0 -1" = 从第 0 个字符取到倒数第一个之前(即砍掉末尾一个字符)。
# 【为什么要判断而不是无脑砍】万一某个版本的宏渲染不带后缀(直接给 "12.5"),
#   无脑砍会把 "12.5" 变成 "12.", 反而更糟。判断一次最稳。
# 【注意】目标 num_str 会在每次调用时被覆盖, 不用手动清理。
# ------------------------------------------------------------
$data modify storage manacore:work a.raw set value "$(num)"
$data modify storage manacore:work a.num_str set value "$(num)"
data modify storage manacore:work a.last set string storage manacore:work a.raw -1
execute if data storage manacore:work a{last:"d"} run data modify storage manacore:work a.num_str set string storage manacore:work a.raw 0 -1
execute if data storage manacore:work a{last:"f"} run data modify storage manacore:work a.num_str set string storage manacore:work a.raw 0 -1
