# ============================================================
# sweetdream:equipment/staff/surge_ebb/skill —— 潮涌，潮枯（法杖·歌者）主动
# ------------------------------------------------------------
# 【谁调用它】cast 分流器（潜行右键）
# 【文案（用户 2026-11-01 原稿）】
#   魔力 500 · 冷却 120 秒。
#   使用后自身每秒流失 2% 生命值。自身的"追随者"全部转化为"追奉者"。
#   自身与"追奉者"每秒对其 5 格内除释放者外的全部生物造成一次相当于释放者最大魔力值
#   ×0.01 的真实伤害并击退 1 格；若目标为玩家，则改为造成相当于释放者最大魔力值
#   ×0.01 的伤害。若有其他玩家因此受伤，则使其获得相当于其自身基础攻击力 ×0.3 的
#   基础攻击力加成，以及相当于其自身最大魔力值 ×0.3 的魔力值上限加成（不可叠加）。
#   持续 12 秒。结束后"追奉者"向自身收回，全部回收后使自身及自身 5 格内的全部玩家
#   恢复全部生命值。
# 【★ 12 秒的每一跳都在 second 里 ★】本文件只负责"起状态 + 转形态"。
# 【★ 追奉者仍然是 zx.j_follower ★】只是多挂一个 zx.se_f，并且把 zx.j_life 抬到
#   400（20 秒）—— 12 秒内不会被自身的到点收回抢走；收场由 end 逐个 kill。
# ============================================================

execute unless score @s zx.job matches 3 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 3 run return fail

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:surge_ebb",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"潮涌，潮枯冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s {"text":"魔力不足（需要 500）","color":"red"}
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:surge_ebb",cooldown_seconds:120.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ① 12 秒状态
scoreboard players set @s zx.se_on 1
scoreboard players operation @s zx.se_end = #now manacore.meta
scoreboard players add @s zx.se_end 240

# ② 追随者 → 追奉者
execute store result storage zx:work se.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work se.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work se.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work se.u3 int 1 run scoreboard players get @s manacore.u3
function sweetdream:equipment/staff/surge_ebb/to_se with storage zx:work se

execute at @s run particle minecraft:splash ~ ~1 ~ 1.4 0.6 1.4 0.15 40 normal
execute at @s run particle minecraft:bubble_column_up ~ ~ ~ 1.0 0.4 1.0 0.02 20 normal
execute at @s run playsound minecraft:entity.player.swim player @a ~ ~ ~ 1.0 0.7
