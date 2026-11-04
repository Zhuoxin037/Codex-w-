# ============================================================
# sweetdream:equipment/armor/bulwark/expire —— 撤掉受击加的基础攻击力
# ------------------------------------------------------------
# 【为什么必须按账本减】面板里混着别的装备加成，反推会算错（charge/mode_off 同一个坑）。
# ============================================================

execute if score @s zx.bw_st matches 0 run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

scoreboard players operation #bw_neg zx.meta = @s zx.bw_atk
scoreboard players set #bw_m1 zx.meta -1
scoreboard players operation #bw_neg zx.meta *= #bw_m1 zx.meta
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #bw_neg zx.meta
function manacore:api/stats/add

scoreboard players set @s zx.bw_atk 0
scoreboard players set @s zx.bw_st 0
