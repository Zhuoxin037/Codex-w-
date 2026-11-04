# ============================================================
# sweetdream:equipment/staff/surge_ebb/buff —— 潮涌，潮枯：受伤玩家获得加攻加蓝
# ------------------------------------------------------------
# 【执行者】被这一跳打到的玩家
# 【文案】使其获得相当于其自身基础攻击力 ×0.3 的基础攻击力加成，
#   以及相当于其自身最大魔力值 ×0.3 的魔力值上限加成（不可叠加）。
# 【★ 不可叠加怎么保证 ★】zx.se_b_until 还在未来 = 已经有一份在生效 → 直接返回。
# 【★ 账本 zx.se_b_atk / zx.se_b_mm ★】存"值 ×0.3×100"的整数（×100 是为了保留
#   0.01 精度），到期按同一账本取负减回（同 牺牲/肉盾 的成对加减写法）。
# ============================================================

execute if score @s zx.se_b_until > #now manacore.meta run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ① 基础攻击力 +30%
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set @s zx.se_b_atk 0
execute store result score @s zx.se_b_atk run data get storage manacore:out r.value 30
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.01 run scoreboard players get @s zx.se_b_atk
function manacore:api/stats/add

# ② 最大魔力值上限 +30%
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set @s zx.se_b_mm 0
execute store result score @s zx.se_b_mm run data get storage manacore:out r.value 30
data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.01 run scoreboard players get @s zx.se_b_mm
function manacore:api/stats/add

# ③ 12 秒
scoreboard players operation @s zx.se_b_until = #now manacore.meta
scoreboard players add @s zx.se_b_until 240

execute at @s run particle minecraft:bubble ~ ~1 ~ 0.5 0.5 0.5 0.02 8 normal
