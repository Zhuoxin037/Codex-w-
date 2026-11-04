advancement revoke @s only sweetdream:equipment/armor/cease_war_hit
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0
execute unless entity @s[tag=zx.s2_cw] run return 0
execute unless score @s zx.s2_cw_end > #now manacore.meta run return 0
execute unless score @s zx.job matches 2 run return 0
execute unless items entity @s armor.chest *[custom_data~{zx:["cease_war"]}] run return 0
function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",value:10.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
