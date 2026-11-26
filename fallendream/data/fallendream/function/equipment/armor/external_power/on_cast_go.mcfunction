# ============================================================
# fallendream:equipment/armor/external_power/on_cast_go —— 超限·体外供能「返还 10% 魔力」做事层
# ------------------------------------------------------------
# 【执行者】玩家  【前置】on_cast 已备份 manacore:work a 与 in arg、已读 #ep_mana
# 【★ early return 只返回本函数；on_cast 的还原照常执行 ★】
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# 判施法那一刻魔力 >70%
execute unless score @s zx.ep_pre_t = #now manacore.meta run return 0
execute unless score @s zx.ep_pre matches 1 run return 0
scoreboard players set @s zx.ep_pre 0

scoreboard players set #ep_10 zx.meta 10
scoreboard players operation #ep_ret zx.meta = #ep_mana zx.meta
scoreboard players operation #ep_ret zx.meta /= #ep_10 zx.meta
execute if score #ep_ret zx.meta matches ..0 run return 0

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #ep_ret zx.meta
function manacore:api/mana/add
