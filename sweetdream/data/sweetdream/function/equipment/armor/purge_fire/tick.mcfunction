# ============================================================
# sweetdream:equipment/armor/purge_fire/tick —— 涤火：5 秒加成到期撤除
# ------------------------------------------------------------
# 【谁调用它】core/tick：execute as @a run function sweetdream:equipment/armor/purge_fire/tick
# 【执行者】全体玩家 @a（每刻）
# 【做什么】zx.pf_on = 1 且 zx.pf_until <= #now → 按账本 zx.pf_atk 取负减回
#   base_attack，清账本与标记。没在加成期就第一行退出，零开销。
# ============================================================

execute unless score @s zx.pf_on matches 1 run return 0
execute if score @s zx.pf_until > #now manacore.meta run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
scoreboard players set #pf_neg zx.meta 0
scoreboard players operation #pf_neg zx.meta -= @s zx.pf_atk
execute store result storage manacore:in arg.value double 0.002 run scoreboard players get #pf_neg zx.meta
function manacore:api/stats/add

scoreboard players set @s zx.pf_atk 0
scoreboard players set @s zx.pf_on 0
