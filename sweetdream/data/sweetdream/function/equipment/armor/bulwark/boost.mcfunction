# ============================================================
# sweetdream:equipment/armor/bulwark/boost —— 把本次额外自伤转成基础攻击力加成
# ------------------------------------------------------------
# 【入参】#bw_x zx.meta = 本次额外受到伤害（毫点，= 要加的基础攻击力）
# 【★ 不可叠加 ★】先按账本把上一份减回去，再挂新的（时长重置为 10 秒）。
#   账本 zx.bw_atk 存"加了多少（毫点）"，减法在 expire 里做，两处必须成对。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 撤掉旧的那一份
execute if score @s zx.bw_st matches 1 run function sweetdream:equipment/armor/bulwark/expire

# ② 记新账本
scoreboard players operation @s zx.bw_atk = #bw_x zx.meta
scoreboard players set @s zx.bw_st 1
scoreboard players operation @s zx.bw_until = #now manacore.meta
scoreboard players add @s zx.bw_until 200

# ③ 加到面板（毫点 ×0.001 = 点）
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get @s zx.bw_atk
function manacore:api/stats/add
