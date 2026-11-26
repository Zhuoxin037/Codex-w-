# ============================================================
# fallendream:equipment/staff/surge_ebb/second —— 潮涌，潮枯：12 秒里每秒一跳
# ------------------------------------------------------------
# 【谁调用它】lib/second：execute as @a at @s run ...
# 【顺序】
#   ① 到点先收场（end 会把 se_on 清零，所以要紧跟一个重判）
#   ② 自身每秒流失 2% 生命（真实伤害）
#   ③ 算本秒的伤害值（释放者最大魔力 ×0.01，追奉者共用这一个数）
#   ④ 自己 5 格一跳 → 每个"自己的"追奉者 5 格一跳
# ============================================================

# 【门】@a 广播调用：既不拿潮涌、也不在 12 秒状态里 → 直接跳过。
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["surge_ebb"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["surge_ebb"]}] unless score @s zx.se_on matches 1 run return 0

execute unless score @s zx.se_on matches 1 run return 0
execute if score @s zx.se_end <= #now manacore.meta run function fallendream:equipment/staff/surge_ebb/end
execute unless score @s zx.se_on matches 1 run return 0

# ② 每秒流失 2% 最大生命
function fallendream:lib/max_health_score
scoreboard players operation #mp_src zx.meta = #max_hp zx.meta
scoreboard players set #mp_mul zx.meta 20
function fallendream:lib/math/mul_permille
execute store result storage zx:work se.v double 0.001 run scoreboard players get #mp_out zx.meta
function fallendream:equipment/staff/surge_ebb/self_hurt with storage zx:work se

# ③ 本秒伤害值 = 释放者最大魔力值 ×0.01
#   ★ 这里**不调 manacore:api/damage/calc** ★ 那条接口会抛 damage_calc 事件，
#     于是每秒的每一跳都会被当成"一次技能结算"—— 会把 余响 攒着的
#     "下一次技能伤害 +5%" 顺手吃掉。文案写的是"相当于最大魔力值 ×0.01"，
#     直接读属性再乘，语义更准，也没有副作用。
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #se_mm zx.meta 0
execute store result score #se_mm zx.meta run data get storage manacore:out r.value 100
execute store result storage zx:work se.v double 0.0001 run scoreboard players get #se_mm zx.meta

# 归属用（aoe 里拼 target 的 UUID）
execute store result storage zx:work se.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work se.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work se.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work se.u3 int 1 run scoreboard players get @s manacore.u3

# ④ 自己
tag @s add zx.se_c
execute at @s run function fallendream:equipment/staff/surge_ebb/aoe with storage zx:work se

# ⑤ 自己的追奉者（先按 UUID 打上 zx.se_m，别人的追奉者不会进来）
function fallendream:equipment/staff/surge_ebb/mark_mine with storage zx:work se
execute at @s as @e[tag=zx.se_m,distance=0..] at @s run function fallendream:equipment/staff/surge_ebb/aoe with storage zx:work se
tag @e[tag=zx.se_m,distance=0..] remove zx.se_m

tag @s remove zx.se_c
