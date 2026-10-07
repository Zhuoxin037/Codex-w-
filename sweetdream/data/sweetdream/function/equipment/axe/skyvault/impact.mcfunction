# ============================================================
# sweetdream:equipment/axe/skyvault/impact —— 天穹俯冲落点结算
# ------------------------------------------------------------
# 【谁调用它】dive_tick 在"撞墙/命中/落地/步数用尽"的那一 tick
# 【执行者】施法者本人, 位置就是落点
# 【文案】
#   ① 半径 5 格冲击: 范围内全部生物吃"最大魔力 ×0.12"; 带「升痕」的每层 +5%(走公共加伤钩子)。
#   ② 每命中一个带「升痕」的, 消耗其全部「升痕」, 每层额外挨一次"基础攻击力 ×2"。
#   ③ 若总共至少消耗 6 层「升痕」, 技能冷却 -30 秒。
# 【★ 顺序 ★】先算完冲击伤害(要读层数), 再清升痕 —— 反了就全变 0 层。
# ============================================================

# ① 摘下俯冲标记 + 给自己打"居高临下"标记 + 落点表现
#   【zx.sv_high 干什么】让本次冲击(以及下面的额外 ×2 伤害)能被 internal/damage/stg_mul
#   认成"来自更高处的攻击" —— 落地那一瞬玩家未必真的比目标高, 只比 Y 会漏判升痕加伤。
tag @s remove zx.sv_dive
scoreboard players reset @s zx.sv_step
tag @s remove zx.sv_high
tag @s add zx.sv_high
execute at @s run particle minecraft:explosion ~ ~0.5 ~ 2.4 0.4 2.4 0.0 1 normal
execute at @s run particle minecraft:cloud ~ ~1 ~ 3.0 0.6 3.0 0.05 40 normal
execute at @s run particle minecraft:poof ~ ~0.5 ~ 3.0 0.6 3.0 0.05 30 normal
execute at @s run playsound minecraft:entity.generic.explode player @a ~ ~ ~ 1.0 0.7
execute at @s run playsound minecraft:item.trident.thunder player @a ~ ~ ~ 0.8 1.2

# ② 圈目标: 半径 5 格内全部生物, 再按「升痕」层数分组(0 / 1 / 2 / >=3)
tag @e[tag=zx.sv_aoe] remove zx.sv_aoe
tag @e[tag=zx.sv_g1] remove zx.sv_g1
tag @e[tag=zx.sv_g2] remove zx.sv_g2
tag @e[tag=zx.sv_g3] remove zx.sv_g3
tag @e[tag=zx.sv_none] remove zx.sv_none
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..5] add zx.sv_aoe
execute as @e[tag=zx.sv_aoe] if score @s zx.stg matches 1 run tag @s add zx.sv_g1
execute as @e[tag=zx.sv_aoe] if score @s zx.stg matches 2 run tag @s add zx.sv_g2
execute as @e[tag=zx.sv_aoe] if score @s zx.stg matches 3.. run tag @s add zx.sv_g3
execute as @e[tag=zx.sv_aoe] unless score @s zx.stg matches 1.. run tag @s add zx.sv_none

# ③ 冲击伤害: 半径 5 内全部生物吃"最大魔力 ×0.12"
#   【每层升痕 +5% 现在由公共钩子 internal/damage/stg_mul 按每个目标自身层数施加,
#    所以这里只要打一遍全体、不用再按层分组】(zx.sv_none/g1/g2/g3 仍用于 ④⑤ 的计数与额外伤害)
data modify storage zx:work sv set value {tag:"@e[tag=zx.sv_aoe]"}
function sweetdream:equipment/axe/skyvault/aoe with storage zx:work sv

# ④ 统计这次一共消耗了几层「升痕」(1 层组算 1, 2 层组算 2, 3 层组算 3)
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

# ⑤ 额外伤害: 每命中一个带「升痕」的, 每层额外挨一次"基础攻击力 ×2"
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0}
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

# ⑥ 至少消耗 6 层 -> 冷却 -30 秒(600 tick)
execute if score #sv_tot zx.meta matches 6.. run data modify storage manacore:in arg set value {uuid:""}
execute if score #sv_tot zx.meta matches 6.. run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #sv_tot zx.meta matches 6.. run data modify storage manacore:in arg.skill set value "sweetdream:skyvault"
execute if score #sv_tot zx.meta matches 6.. run data modify storage manacore:in arg.ticks set value 600
execute if score #sv_tot zx.meta matches 6.. run function manacore:api/cooldown/reduce
execute if score #sv_tot zx.meta matches 6.. run tellraw @s [{"text":"天穹·升痕共鸣: 冷却 ","color":"aqua"},{"text":"-30","color":"white"},{"text":" 秒","color":"aqua"}]

# ⑦ 清掉这些生物的「升痕」+ 收尾标签 —— 升痕的计时也一起清(与 status/decay_stg 一致)
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

# ⑧ 摘掉"居高临下"标记(只服务于本次俯冲)
tag @s remove zx.sv_high
