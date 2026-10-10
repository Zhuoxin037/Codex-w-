# ------------------------------------------------------------
# internal/stats/mul_calc —— 定点乘法实现
# 【宏参数】manacore:work.a {uuid,key,value}
# 【原理】#a(#原值x1000) *= #b(#倍率x100) 会得到 x100000 的量级,
#         再 /= #100 就还原成 x1000 的定点数。
# 【为什么倍率取 x100】计分板是 32 位有符号整数(上限 21.4 亿)。两个操作数
#         都按 x1000 相乘的话, 中间量到 x1000000, 原值 x 倍率 超过约 2147
#         就溢出成负数。倍率降一个数量级后, 可承受范围提升到约 21474。
#         倍率保留 2 位小数(1.2 / 1.15 都够用)。
# 【典型用例】max_mana 5000 x 1.2 = 6000, 旧算法会溢出, 新算法正常。
# 【★ intovf-ok ★】本函数就是"为了让定点乘法够用"而专门设计的: 倍率刻意取 x100 而不是
#   x1000, 把可承受范围从 ~2147 提到 ~21474(见上面第 6-9 行)。量级是**算过账**的,
#   不套 check.py 的 intovf 规则(那条只拦"没算过账"的新写法)。
#   ⚠ 仍然会溢出的边界: 原值 x 倍率 > ~21,474。典型用例 5000x1.2=6000 安全;
#     但 max_mana 类数值被推到 2 万以上时(层层加成叠加)要回来看这里。
# ------------------------------------------------------------
$execute store result score #a manacore.math run data get storage manacore:players "$(uuid)".stats."$(key)" 1000
execute store result score #b manacore.math run data get storage manacore:work a.value 100
scoreboard players operation #a manacore.math *= #b manacore.math
scoreboard players operation #a manacore.math /= #100 manacore.meta
$execute store result storage manacore:players "$(uuid)".stats."$(key)" double 0.001 run scoreboard players get #a manacore.math
