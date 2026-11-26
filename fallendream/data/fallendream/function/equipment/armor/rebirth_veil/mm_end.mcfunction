# ============================================================
# fallendream:equipment/armor/rebirth_veil/mm_end —— 超限·复纱：+20% 上限到点退还
# ------------------------------------------------------------
# 【执行者】玩家  【调用】batch21/player_tick(到期刻已过)
# 【★ 退完必须把当前魔力写回一次 ★】上限变小之后当前魔力可能超上限;
#   照 dusk_dawn/apply_mana 的做法读一次再 set 回去, 等于夹紧。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

scoreboard players set #rbv_neg zx.meta 0
scoreboard players operation #rbv_neg zx.meta -= @s zx.rbv_mm

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #rbv_neg zx.meta
function manacore:api/stats/add

scoreboard players set @s zx.rbv_mm 0
scoreboard players set @s zx.rbv_mm_end 0

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
