# ============================================================
# sweetdream:equipment/sword/gousi/miss_hit —— 没拉到位那一下的伤害（宏）
# ------------------------------------------------------------
# 【执行者】玩家
# 【宏参数】sweetdream:work gs {own}
# 【算法】最大魔力值 ×0.04（×10 定点后 ×4 ÷1000）
# ============================================================
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get

scoreboard players set #gs_mm zx.meta 0
execute store result score #gs_mm zx.meta run data get storage manacore:out r.max 10
scoreboard players set #gs_k zx.meta 4
scoreboard players operation #gs_d zx.meta = #gs_mm zx.meta
scoreboard players operation #gs_d zx.meta *= #gs_k zx.meta
scoreboard players operation #gs_d zx.meta /= #1000 zx.meta
execute if score #gs_d zx.meta matches ..0 run scoreboard players set #gs_d zx.meta 1

$data modify storage zx:work a set value {target:"@e[tag=zx.gs_$(own),limit=1]",type:"minecraft:player_attack"}
execute store result storage zx:work a.num double 1 run scoreboard players get #gs_d zx.meta
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function sweetdream:internal/damage/with_from with storage zx:work a
