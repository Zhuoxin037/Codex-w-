# ============================================================
# sweetdream:equipment/armor/ebb_tide/speed_dn -- 生物在海浪上的移速削减查表
# ------------------------------------------------------------
# 【执行者】那只生物(@s)   【入参】zx.et_e = 当前档位(0..30)   【账本】zx.et_du(0/1)
# 【★ 本文件由 .workbuddy 的生成器一次写全 -- 手工增删档位必错 ★】
# 【★ 30 档写全 ★】文案是 -1% ... -30%。漏一档 => 到顶后掉回初始值,
#   表现是减速到一半突然又跑起来了(静默、零日志)。
# 【★ 这里是 add_multiplied_total 的**负值** ★】-0.30 = 总移速 x(1-0.30)。
# ============================================================

# ① 挂过才摘
execute if score @s zx.et_du matches 1 run attribute @s minecraft:movement_speed modifier remove sweetdream:et_dn
# ② 档位 0 => 记【没挂】并收工
execute unless score @s zx.et_e matches 1.. run scoreboard players set @s zx.et_du 0
execute unless score @s zx.et_e matches 1.. run return 0

execute if score @s zx.et_e matches 1 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.01 add_multiplied_total
execute if score @s zx.et_e matches 2 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.02 add_multiplied_total
execute if score @s zx.et_e matches 3 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.03 add_multiplied_total
execute if score @s zx.et_e matches 4 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.04 add_multiplied_total
execute if score @s zx.et_e matches 5 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.05 add_multiplied_total
execute if score @s zx.et_e matches 6 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.06 add_multiplied_total
execute if score @s zx.et_e matches 7 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.07 add_multiplied_total
execute if score @s zx.et_e matches 8 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.08 add_multiplied_total
execute if score @s zx.et_e matches 9 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.09 add_multiplied_total
execute if score @s zx.et_e matches 10 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.10 add_multiplied_total
execute if score @s zx.et_e matches 11 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.11 add_multiplied_total
execute if score @s zx.et_e matches 12 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.12 add_multiplied_total
execute if score @s zx.et_e matches 13 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.13 add_multiplied_total
execute if score @s zx.et_e matches 14 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.14 add_multiplied_total
execute if score @s zx.et_e matches 15 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.15 add_multiplied_total
execute if score @s zx.et_e matches 16 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.16 add_multiplied_total
execute if score @s zx.et_e matches 17 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.17 add_multiplied_total
execute if score @s zx.et_e matches 18 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.18 add_multiplied_total
execute if score @s zx.et_e matches 19 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.19 add_multiplied_total
execute if score @s zx.et_e matches 20 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.20 add_multiplied_total
execute if score @s zx.et_e matches 21 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.21 add_multiplied_total
execute if score @s zx.et_e matches 22 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.22 add_multiplied_total
execute if score @s zx.et_e matches 23 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.23 add_multiplied_total
execute if score @s zx.et_e matches 24 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.24 add_multiplied_total
execute if score @s zx.et_e matches 25 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.25 add_multiplied_total
execute if score @s zx.et_e matches 26 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.26 add_multiplied_total
execute if score @s zx.et_e matches 27 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.27 add_multiplied_total
execute if score @s zx.et_e matches 28 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.28 add_multiplied_total
execute if score @s zx.et_e matches 29 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.29 add_multiplied_total
execute if score @s zx.et_e matches 30 run attribute @s minecraft:movement_speed modifier add sweetdream:et_dn -0.30 add_multiplied_total

# ③ 记账: 现在已经挂上了
scoreboard players set @s zx.et_du 1
