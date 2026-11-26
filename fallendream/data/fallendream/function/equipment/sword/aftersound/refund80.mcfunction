# ============================================================
# fallendream:equipment/sword/aftersound/refund80 —— 余响：收回时给 80 魔力
# ------------------------------------------------------------
# 【执行者】主人 3 格内的玩家（recall 里 `execute at 主人 as @a[distance=..3]`）
# 【和 profession/singer/refund_player 同款】只把基数 50 换成 80：
#   总额 = 80 + 10 × 合奏层数（#j_duet_refund）
# ============================================================

function fallendream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",value:80.0}
scoreboard players operation #j_duet_mana zx.meta = #j_duet_refund zx.meta
scoreboard players set #j_duet_ten zx.meta 10
scoreboard players operation #j_duet_mana zx.meta *= #j_duet_ten zx.meta
scoreboard players add #j_duet_mana zx.meta 80
execute store result storage manacore:in arg.value double 1 run scoreboard players get #j_duet_mana zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
execute if score #j_duet_refund zx.meta matches 1.. run function fallendream:profession/singer/refund_heal
