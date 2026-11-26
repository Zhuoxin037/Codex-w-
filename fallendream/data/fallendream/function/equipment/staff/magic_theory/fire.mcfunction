# ============================================================
# fallendream:equipment/staff/magic_theory/fire —— 花一枚「导轨」打一发
# ------------------------------------------------------------
# 【执行者】玩家
# 【射程】基础 40 格(160 步 × 0.25) / 超限 48 格(192 步) —— 步数上限塞给 ray
# 【★ 只有还有导轨时才扣】补射(paid)进来时导轨本来就是 0, 无脑 remove 会变成 -1
# 【★ 选择器半径 52 = 48 格 + 4 格余量】tag 只由 ray 沿射线贴, 半径放宽不会误伤;
#   半径是选择器字面量, 不能按分数算 ⇒ 只能固定写一个够用的值
# ============================================================
execute if score @s zx.s2_rail matches 1.. run scoreboard players remove @s zx.s2_rail 1
tag @e[tag=zx.s2_rail_target,distance=..52] remove zx.s2_rail_target
scoreboard players set #s2_rail_step zx.meta 0
scoreboard players set #s2_rail_max zx.meta 160
execute if score @s zx.mt_ol matches 1 run scoreboard players set #s2_rail_max zx.meta 192
# 档位交给 count(它在生物身上执行, 读不到主人的手持物)
scoreboard players operation #s2_rail_ol zx.meta = @s zx.mt_ol
execute anchored eyes positioned ^ ^ ^ run function fallendream:equipment/staff/magic_theory/ray
execute unless entity @e[tag=zx.s2_rail_target,distance=..52,limit=1] run return 0
function fallendream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work s2_rail_damage set from storage manacore:out r.damage
data modify storage zx:work s2_b_s2_rail_damage set value {n:0,d:1}
data modify storage zx:work s2_b_s2_rail_damage set from storage manacore:out r.s2_b_damage
function fallendream:lib/uuid
data modify storage zx:work s2_rail.owner set from storage zx:data self.uuid
execute store result storage zx:work s2_rail.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work s2_rail.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work s2_rail.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work s2_rail.u3 int 1 run scoreboard players get @s manacore.u3
execute as @e[tag=zx.s2_rail_target,distance=..52,limit=1] at @s run function fallendream:equipment/staff/magic_theory/hit with storage zx:work s2_rail
tag @e[tag=zx.s2_rail_target,distance=..52] remove zx.s2_rail_target
