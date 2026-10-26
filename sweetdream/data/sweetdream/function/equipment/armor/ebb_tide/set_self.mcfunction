effect give @s minecraft:speed 2 0 true
execute unless entity @e[tag=zx.et_wave,distance=..1,limit=1] run return 0
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",value:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
scoreboard players add @s zx.regen_extra 20
execute store result storage zx:work et_owner.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work et_owner.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work et_owner.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work et_owner.u3 int 1 run scoreboard players get @s manacore.u3
function sweetdream:equipment/armor/ebb_tide/set_self_go with storage zx:work et_owner
