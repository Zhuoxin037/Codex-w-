# ============================================================
# sweetdream:equipment/staff/surge_ebb/buff_end —— 潮涌，潮枯：加攻加蓝到期撤回
# ------------------------------------------------------------
# 【谁调用它】lib/second：execute as @a[scores={zx.se_b_until=1..}] run ...
# 【执行者】玩家
# 【★ 按账本取负减回 ★】不是"再算一遍 0.3×当前值" —— 期间玩家的基础攻击力
#   可能被别的装备改过，那样会减错（同 牺牲/肉盾 的账本口径）。
# ============================================================

execute if score @s zx.se_b_until > #now manacore.meta run return 0
scoreboard players set @s zx.se_b_until 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double -0.01 run scoreboard players get @s zx.se_b_atk
function manacore:api/stats/add
scoreboard players set @s zx.se_b_atk 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double -0.01 run scoreboard players get @s zx.se_b_mm
function manacore:api/stats/add
scoreboard players set @s zx.se_b_mm 0
