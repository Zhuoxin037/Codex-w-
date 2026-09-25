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
# ------------------------------------------------------------
$execute store result score #a manacore.math run data get storage manacore:players "$(uuid)".stats."$(key)" 1000
execute store result score #b manacore.math run data get storage manacore:work a.value 100
scoreboard players operation #a manacore.math *= #b manacore.math
scoreboard players operation #a manacore.math /= #100 manacore.meta
$execute store result storage manacore:players "$(uuid)".stats."$(key)" double 0.001 run scoreboard players get #a manacore.math
