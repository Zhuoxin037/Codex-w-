# ============================================================
# sweetdream:equipment/armor/ebb_tide/speed_up -- 自身在海浪上的移速加成查表
# ------------------------------------------------------------
# 【执行者】玩家(@s)   【入参】zx.et_s = 当前档位(0..20)   【账本】zx.et_su(0/1)
# 【★ 本文件由 .workbuddy 的生成器一次写全 -- 手工增删档位必错 ★】
# 【★ 为什么必须查表 ★】attribute ... modifier add 的**值只能是命令行字面量**
#   (RULES 字面量禁区); 而文案要的是 +1% ... +20% 共 20 档。
#   => 20 条字面量各写一条, 一条都不能少 -- 少了就会踩折径 pick_mul 那个老坑:
#      到顶后**掉回初始值**(静默、零日志)。
# 【★ 为什么带 zx.et_su 账本 ★】remove 一个**不存在**的 modifier 会失败
#   (照 beach_vein/armor_sync 的口径: 失败会截断整个函数) => 只能【挂过才摘】。
# ============================================================

# ① 挂过才摘
execute if score @s zx.et_su matches 1 run attribute @s minecraft:movement_speed modifier remove sweetdream:et_up
# ② 档位 0 => 记【没挂】并收工
execute unless score @s zx.et_s matches 1.. run scoreboard players set @s zx.et_su 0
execute unless score @s zx.et_s matches 1.. run return 0

execute if score @s zx.et_s matches 1 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.01 add_multiplied_total
execute if score @s zx.et_s matches 2 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.02 add_multiplied_total
execute if score @s zx.et_s matches 3 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.03 add_multiplied_total
execute if score @s zx.et_s matches 4 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.04 add_multiplied_total
execute if score @s zx.et_s matches 5 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.05 add_multiplied_total
execute if score @s zx.et_s matches 6 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.06 add_multiplied_total
execute if score @s zx.et_s matches 7 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.07 add_multiplied_total
execute if score @s zx.et_s matches 8 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.08 add_multiplied_total
execute if score @s zx.et_s matches 9 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.09 add_multiplied_total
execute if score @s zx.et_s matches 10 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.10 add_multiplied_total
execute if score @s zx.et_s matches 11 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.11 add_multiplied_total
execute if score @s zx.et_s matches 12 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.12 add_multiplied_total
execute if score @s zx.et_s matches 13 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.13 add_multiplied_total
execute if score @s zx.et_s matches 14 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.14 add_multiplied_total
execute if score @s zx.et_s matches 15 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.15 add_multiplied_total
execute if score @s zx.et_s matches 16 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.16 add_multiplied_total
execute if score @s zx.et_s matches 17 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.17 add_multiplied_total
execute if score @s zx.et_s matches 18 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.18 add_multiplied_total
execute if score @s zx.et_s matches 19 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.19 add_multiplied_total
execute if score @s zx.et_s matches 20 run attribute @s minecraft:movement_speed modifier add sweetdream:et_up 0.20 add_multiplied_total

# ③ 记账: 现在已经挂上了
scoreboard players set @s zx.et_su 1
