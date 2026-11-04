scoreboard players remove @s zx.s2_rail 1
tag @e[tag=zx.s2_rail_target,distance=..42] remove zx.s2_rail_target
scoreboard players set #s2_rail_step zx.meta 0
execute anchored eyes positioned ^ ^ ^ run function sweetdream:equipment/staff/magic_theory/ray
execute unless entity @e[tag=zx.s2_rail_target,distance=..42,limit=1] run return 0
function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work s2_rail_damage set from storage manacore:out r.damage
data modify storage zx:work s2_b_s2_rail_damage set value {n:0,d:1}
data modify storage zx:work s2_b_s2_rail_damage set from storage manacore:out r.s2_b_damage
function sweetdream:lib/uuid
data modify storage zx:work s2_rail.owner set from storage zx:data self.uuid
execute store result storage zx:work s2_rail.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work s2_rail.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work s2_rail.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work s2_rail.u3 int 1 run scoreboard players get @s manacore.u3
execute as @e[tag=zx.s2_rail_target,distance=..42,limit=1] at @s run function sweetdream:equipment/staff/magic_theory/hit with storage zx:work s2_rail
tag @e[tag=zx.s2_rail_target,distance=..42] remove zx.s2_rail_target
