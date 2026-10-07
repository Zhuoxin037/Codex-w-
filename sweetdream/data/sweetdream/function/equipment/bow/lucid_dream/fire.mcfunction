# ============================================================
# sweetdream:equipment/bow/lucid_dream/fire —— 命中结算(宏 {target,shooter,uuid,arrow})
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s = victim)
# 【判定分支】
#   · 目标带「白昼梦」(tag=zx.status.dream) 或 处于时停(tag=zx.stop):
#       A) 白昼梦 且 自身「梦回」>= 3: 触发大效果 -> big(伤害+清白昼梦+清梦回+术阵+标记)
#       B) 否则: 「梦回」+1(上限 5)
#   · 两者都不是: 什么都不做(梦回不涨)
# 【X 取多少】文案"X 为「梦回」层数"; 触发大效果时层数就是 3/4/5(≥3)。
#   伤害 = 当前魔力 ×0.01×X, 持续 = X 秒。
# ============================================================

# ① 快照 ok?
execute unless data storage zx:work ld.snap{ok:1b} run return 0

# ② 目标是不是白昼梦 / 时停
scoreboard players set #ld_isDream zx.meta 0
scoreboard players set #ld_isStop zx.meta 0
$execute as $(target) if entity @s[tag=zx.status.dream] run scoreboard players set #ld_isDream zx.meta 1
$execute as $(target) if entity @s[tag=zx.stop] run scoreboard players set #ld_isStop zx.meta 1

# ③ 大效果: 白昼梦 且 本发用的 combo >= 3
#    combo 来自快照 = 射击那一刻的梦回层数
scoreboard players set #ld_com zx.meta 0
execute store result score #ld_com zx.meta run data get storage zx:work ld.snap.combo
execute if score #ld_isDream zx.meta matches 1 if score #ld_com zx.meta matches 3.. run function sweetdream:equipment/bow/lucid_dream/big with storage zx:work ld
execute if score #ld_isDream zx.meta matches 1 if score #ld_com zx.meta matches 3.. run return 0

# ④ 普通情况: 是白昼梦 或 时停 -> 梦回 +1(上限 5)
execute unless score #ld_isDream zx.meta matches 1 unless score #ld_isStop zx.meta matches 1 run return 0
$execute as $(shooter) run scoreboard players add @s zx.ld_dream 1
$execute as $(shooter) if score @s zx.ld_dream matches 6.. run scoreboard players set @s zx.ld_dream 5

# 表现
$execute at $(target) run particle minecraft:end_rod ~ ~1 ~ 0.8 0.6 0.8 0.05 15 normal
$execute at $(target) run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.8 1.6

# ⑤ 收尾
tag @e[tag=zx.ld_v] remove zx.ld_v
tag @e[tag=zx.ld_pl] remove zx.ld_pl
tag @e[tag=zx.ld_arr] remove zx.ld_arr
