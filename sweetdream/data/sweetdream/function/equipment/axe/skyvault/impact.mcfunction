# ============================================================
# sweetdream:equipment/axe/skyvault/impact —— 天穹俯冲落点结算
# ------------------------------------------------------------
# 【谁调用它】dive_tick 在"撞墙/命中/落地/步数用尽"的那一 tick
# 【执行者】施法者本人, 位置就是落点
# 【文案(原版)】
#   ① 半径 5 格冲击: 范围内全部生物吃"最大魔力 ×0.12"; 带「升痕」的每层 +5%(公共钩子)。
#   ② 每命中一个带「升痕」的, 消耗其全部「升痕」, 每层额外挨一次"基础攻击力 ×2"。
#   ③ 若总共至少消耗 6 层「升痕」, 技能冷却 -30 秒。
# 【文案(超限 · 2026-10-23 批 K4)】
#   ① 半径 **6** 格(不是 5); 伤害仍是 最大魔力 ×0.12; 每层「升痕」+**10%**(见 stg_mul)。
#   ② 每层额外一次"基础攻击力 ×**3**"(不是 2)。
#   ③ ≥6 层: 冷却 -**35** 秒(不是 30)。
#   ④ ★ 新增连锁 ★ ≥10 层: 再跃升 6 格, 0.5 秒后**自动**俯冲(不用再按), 落地后
#      半径 5 格内全部生物吃"**当前**魔力 ×0.1", 并被挂 1 层「升痕」。
# 【★ 两段怎么分: zx.sv_cn ★】0 = 第一段(含原版); 1 = 连锁段(由 ol_chain 设)。
#   连锁段只做"半径 5 + 当前魔力 ×0.1 + 挂 1 层升痕", 不再消耗升痕、不再减冷却。
# 【★ 两个快照: #sv_ol / #sv_cn ★】#sv_ol 在 ① 从玩家身上读走; #sv_cn 同理。
#   为什么不用 @s 上的计分项直接判: 本函数中途会把它们清零(⑩ / ⑤), 清零之后再
#   `if score @s ... matches 1` 判自己 = 永远假(死分支)。快照是 zx.meta 上的假玩家,
#   只在本函数里读, 不受清零影响。
# 【★ 顺序 ★】先算完冲击伤害(要读层数), 再清升痕 —— 反了就全变 0 层。
# ============================================================

# ① 摘下俯冲标记 + 给自己打"居高临下"标记 + 两个快照 + 落点表现
#   【zx.sv_high 干什么】让本次冲击(以及下面的额外伤害)能被 internal/damage/stg_mul
#   认成"来自更高处的攻击" —— 落地那一瞬玩家未必真的比目标高, 只比 Y 会漏判升痕加伤。
tag @s remove zx.sv_dive
scoreboard players reset @s zx.sv_step
tag @s remove zx.sv_high
tag @s add zx.sv_high
scoreboard players set #sv_ol zx.meta 0
execute if score @s zx.sv_ol matches 1 run scoreboard players set #sv_ol zx.meta 1
scoreboard players set #sv_cn zx.meta 0
execute if score @s zx.sv_cn matches 1 run scoreboard players set #sv_cn zx.meta 1
execute at @s run particle minecraft:explosion ~ ~0.5 ~ 2.4 0.4 2.4 0.0 1 normal
execute at @s run particle minecraft:cloud ~ ~1 ~ 3.0 0.6 3.0 0.05 40 normal
execute at @s run particle minecraft:poof ~ ~0.5 ~ 3.0 0.6 3.0 0.05 30 normal
execute at @s run playsound minecraft:entity.generic.explode player @a ~ ~ ~ 1.0 0.7
execute at @s run playsound minecraft:item.trident.thunder player @a ~ ~ ~ 0.8 1.2

# ② 圈目标: 连锁段 5 格 / 超限第一段 6 格 / 原版第一段 5 格(三行互斥)
tag @e[tag=zx.sv_aoe] remove zx.sv_aoe
tag @e[tag=zx.sv_g1] remove zx.sv_g1
tag @e[tag=zx.sv_g2] remove zx.sv_g2
tag @e[tag=zx.sv_g3] remove zx.sv_g3
tag @e[tag=zx.sv_none] remove zx.sv_none
execute if score #sv_cn zx.meta matches 1 at @s run tag @e[type=!#sweetdream:no_damage,distance=..5] add zx.sv_aoe
execute unless score #sv_cn zx.meta matches 1 if score #sv_ol zx.meta matches 1 at @s run tag @e[type=!#sweetdream:no_damage,distance=..6] add zx.sv_aoe
execute unless score #sv_cn zx.meta matches 1 if score #sv_ol zx.meta matches 0 at @s run tag @e[type=!#sweetdream:no_damage,distance=..5] add zx.sv_aoe

# ③ 分组(只有第一段要用: 连锁段不消耗升痕)
execute unless score #sv_cn zx.meta matches 1 as @e[tag=zx.sv_aoe] if score @s zx.stg matches 1 run tag @s add zx.sv_g1
execute unless score #sv_cn zx.meta matches 1 as @e[tag=zx.sv_aoe] if score @s zx.stg matches 2 run tag @s add zx.sv_g2
execute unless score #sv_cn zx.meta matches 1 as @e[tag=zx.sv_aoe] if score @s zx.stg matches 3.. run tag @s add zx.sv_g3
execute unless score #sv_cn zx.meta matches 1 as @e[tag=zx.sv_aoe] unless score @s zx.stg matches 1.. run tag @s add zx.sv_none

# ④ 冲击伤害
#   第一段(含原版): 最大魔力 ×0.12  -> aoe
#   连锁段:         当前魔力 ×0.10  -> ol_aoe
#   【每层升痕的 +5%/+10% 走公共钩子 internal/damage/stg_mul, 按每个目标自己的层数施加,
#    所以这里只要打一遍全体、不用再按层分组】
data modify storage zx:work sv set value {tag:"@e[tag=zx.sv_aoe]"}
execute if score #sv_cn zx.meta matches 1 run function sweetdream:equipment/axe/skyvault/ol_aoe with storage zx:work sv
execute unless score #sv_cn zx.meta matches 1 run function sweetdream:equipment/axe/skyvault/aoe with storage zx:work sv

# ⑤ 连锁段收尾: 范围内各挂 1 层「升痕」-> 清标签 -> 关掉连锁标记 -> 收工
#   ★ return 必须排在 `set sv_cn 0` 之后、且用**快照**判 —— 先清零再判自己就是死分支。
execute if score #sv_cn zx.meta matches 1 run scoreboard players add @e[tag=zx.sv_aoe] zx.stg 1
execute if score #sv_cn zx.meta matches 1 as @e[tag=zx.sv_aoe] if score @s zx.stg matches 4.. run scoreboard players set @s zx.stg 3
execute if score #sv_cn zx.meta matches 1 run scoreboard players set @e[tag=zx.sv_aoe] zx.stg_t 15
execute if score #sv_cn zx.meta matches 1 at @s run particle minecraft:end_rod ~ ~1 ~ 1.6 0.5 1.6 0.05 24 normal
execute if score #sv_cn zx.meta matches 1 run tag @e[tag=zx.sv_aoe] remove zx.sv_aoe
execute if score #sv_cn zx.meta matches 1 run tag @s remove zx.sv_high
execute if score #sv_cn zx.meta matches 1 run tellraw @s [{"text":"天穹·连锁俯冲: 半径 5 格内全部生物吃到 当前魔力 ×0.1, 各得 1 层「升痕」","color":"aqua"}]
execute if score #sv_cn zx.meta matches 1 run scoreboard players set @s zx.sv_cn 0
execute if score #sv_cn zx.meta matches 1 run return 0

# ⑥ 统计这次一共消耗了几层「升痕」(1 层组算 1, 2 层组算 2, 3 层组算 3)
scoreboard players set #sv_c1 zx.meta 0
scoreboard players set #sv_c2 zx.meta 0
scoreboard players set #sv_c3 zx.meta 0
execute store result score #sv_c1 zx.meta run execute if entity @e[tag=zx.sv_g1]
execute store result score #sv_c2 zx.meta run execute if entity @e[tag=zx.sv_g2]
execute store result score #sv_c3 zx.meta run execute if entity @e[tag=zx.sv_g3]
scoreboard players operation #sv_tot zx.meta = #sv_c1 zx.meta
scoreboard players operation #sv_x zx.meta = #sv_c2 zx.meta
scoreboard players operation #sv_x zx.meta *= #2 zx.meta
scoreboard players operation #sv_tot zx.meta += #sv_x zx.meta
scoreboard players operation #sv_y zx.meta = #sv_c3 zx.meta
scoreboard players operation #sv_y zx.meta *= #3 zx.meta
scoreboard players operation #sv_tot zx.meta += #sv_y zx.meta

# ⑦ 额外伤害: 每命中一个带「升痕」的, 每层额外挨一次"基础攻击力 ×2 / 超限 ×3"
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0}
execute if score #sv_ol zx.meta matches 1 run data modify storage manacore:in arg.attack_mul set value 3.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.sv_g1]",read:"manacore"}
execute if entity @e[tag=zx.sv_g1] run function sweetdream:api/damage
data modify storage zx:in arg set value {target:"@e[tag=zx.sv_g2]",read:"manacore"}
# dup-ok: 文案"每消耗一层额外受一次", g2 = 2 层 -> 打两遍
execute if entity @e[tag=zx.sv_g2] run function sweetdream:api/damage
execute if entity @e[tag=zx.sv_g2] run function sweetdream:api/damage
data modify storage zx:in arg set value {target:"@e[tag=zx.sv_g3]",read:"manacore"}
# dup-ok: 文案"每消耗一层额外受一次", g3 = 3 层 -> 打三遍
execute if entity @e[tag=zx.sv_g3] run function sweetdream:api/damage
# dup-ok: 同上(第 2 遍)
execute if entity @e[tag=zx.sv_g3] run function sweetdream:api/damage
execute if entity @e[tag=zx.sv_g3] run function sweetdream:api/damage

# ⑧ 至少消耗 6 层 -> 冷却 -30 秒(600 tick) / 超限 -35 秒(700 tick)
execute if score #sv_tot zx.meta matches 6.. run data modify storage manacore:in arg set value {uuid:""}
execute if score #sv_tot zx.meta matches 6.. run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #sv_tot zx.meta matches 6.. run data modify storage manacore:in arg.skill set value "sweetdream:skyvault"
execute if score #sv_tot zx.meta matches 6.. run data modify storage manacore:in arg.ticks set value 600
execute if score #sv_tot zx.meta matches 6.. if score #sv_ol zx.meta matches 1 run data modify storage manacore:in arg.ticks set value 700
execute if score #sv_tot zx.meta matches 6.. run function manacore:api/cooldown/reduce
execute if score #sv_tot zx.meta matches 6.. if score #sv_ol zx.meta matches 0 run tellraw @s [{"text":"天穹·升痕共鸣: 冷却 ","color":"aqua"},{"text":"-30","color":"white"},{"text":" 秒","color":"aqua"}]
execute if score #sv_tot zx.meta matches 6.. if score #sv_ol zx.meta matches 1 run tellraw @s [{"text":"天穹·升痕共鸣: 冷却 ","color":"aqua"},{"text":"-35","color":"white"},{"text":" 秒","color":"aqua"}]

# ⑨ 清掉这些生物的「升痕」+ 收尾标签 —— 升痕的计时也一起清(与 status/decay_stg 一致)
scoreboard players reset @e[tag=zx.sv_g1] zx.stg
scoreboard players reset @e[tag=zx.sv_g2] zx.stg
scoreboard players reset @e[tag=zx.sv_g3] zx.stg
scoreboard players reset @e[tag=zx.sv_g1] zx.stg_t
scoreboard players reset @e[tag=zx.sv_g2] zx.stg_t
scoreboard players reset @e[tag=zx.sv_g3] zx.stg_t
tag @e[tag=zx.sv_aoe] remove zx.sv_aoe
tag @e[tag=zx.sv_g1] remove zx.sv_g1
tag @e[tag=zx.sv_g2] remove zx.sv_g2
tag @e[tag=zx.sv_g3] remove zx.sv_g3
tag @e[tag=zx.sv_none] remove zx.sv_none

# ⑩ 摘掉"居高临下"标记 + 关掉这一次的超限快照(连锁段会自己重新打)
tag @s remove zx.sv_high
scoreboard players set @s zx.sv_ol 0

# ⑪ 超限连锁: 这一次至少消耗 10 层「升痕」-> 再跃升 6 格, 0.5 秒后自动俯冲
#   ★ 必须排在 ⑩ **之后**: ol_chain 会把 sv_cn 设成 1, 若排在前面, ⑩ 就会被
#     "这是连锁段"的判断挡住, 于是 sv_high / sv_ol 留在玩家身上(下次施法误判超限)。
#   ★ 用 #sv_ol(① 拍的快照)判, 不用 @s zx.sv_ol(⑩ 已经清零了)。
execute if score #sv_ol zx.meta matches 1 if score #sv_tot zx.meta matches 10.. run function sweetdream:equipment/axe/skyvault/ol_chain
