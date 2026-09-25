# ------------------------------------------------------------
# internal/stats/add_calc —— 定点加法实现
# 【宏参数】manacore:work.a {uuid,key,value}
# 【原理】#a = 原值 x1000, #b = 增量 x1000, 相加后 /=1000 写回 double。
#         data get 的第三个参数就是缩放倍率(四舍五入到整数),
#         execute store 到 double 时的缩放参数则用来还原小数。
# 【精度】SCALE=1000, 即保留 3 位小数; 计分板是 32 位有符号整数, 因此
#         单个数值上限约 2,147,483(即 ±214 万), 一般够用。
# ------------------------------------------------------------
$execute store result score #a manacore.math run data get storage manacore:players "$(uuid)".stats."$(key)" 1000
execute store result score #b manacore.math run data get storage manacore:work a.value 1000
scoreboard players operation #a manacore.math += #b manacore.math
$execute store result storage manacore:players "$(uuid)".stats."$(key)" double 0.001 run scoreboard players get #a manacore.math
