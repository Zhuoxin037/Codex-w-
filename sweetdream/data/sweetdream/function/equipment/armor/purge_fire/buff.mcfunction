# ============================================================
# sweetdream:equipment/armor/purge_fire/buff —— 涤火：基础攻击力 +20%，持续 5 秒
# ------------------------------------------------------------
# 【谁调用它】purge_fire/resolve ③（仅 40% 档）
# 【执行者】受伤的玩家
# 【账本】zx.pf_atk = 触发时 base_attack ×100（照 sacrifice/cast 的写法）；
#   加成值 = zx.pf_atk × 0.002 = base_attack × 0.2；
#   5 秒到期由 tick.mcfunction 按同一账本取负减回，成对加减。
# 【到期】zx.pf_until = #now + 100（100 刻 = 5 秒），zx.pf_on = 1 标记在身
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set @s zx.pf_atk 0
execute store result score @s zx.pf_atk run data get storage manacore:out r.value 100

data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.002 run scoreboard players get @s zx.pf_atk
function manacore:api/stats/add

scoreboard players operation @s zx.pf_until = #now manacore.meta
scoreboard players add @s zx.pf_until 100
scoreboard players set @s zx.pf_on 1
