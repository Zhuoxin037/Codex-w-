# ============================================================
# fallendream:equipment/sword/mana_imbue/refund —— 按 zx.mi_mana 回魔
# ------------------------------------------------------------
# 【单位】zx.mi_mana = 魔力 ×1000（毫魔力点），由主动施法时预算好
# 【上限夹取交给 manacore】api/mana/add 内部夹到最大魔力，这里不判
# ============================================================

execute unless score @s zx.mi_mana matches 1.. run return 0

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage zx:work imr.value set value 0.0
execute store result storage zx:work imr.value double 0.001 run scoreboard players get @s zx.mi_mana
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage zx:work imr.value
function manacore:api/mana/add
