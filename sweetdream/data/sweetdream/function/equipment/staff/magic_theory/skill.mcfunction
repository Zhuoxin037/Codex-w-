execute unless score @s zx.job matches 1 run return fail
execute if score @s zx.s2_rail matches 1.. if score @s zx.s2_rail_end > #now manacore.meta run return run function sweetdream:equipment/staff/magic_theory/fire
execute unless score @s zx.j_orb matches 1.. run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:magic_theory",mana:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:magic_theory",cooldown_seconds:65.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
scoreboard players operation @s zx.s2_rail = @s zx.j_orb
scoreboard players set @s zx.j_orb 0
scoreboard players operation @s zx.s2_rail_end = #now manacore.meta
scoreboard players add @s zx.s2_rail_end 240
function sweetdream:lib/uuid
data modify storage zx:work s2_rail.owner set from storage zx:data self.uuid
execute store result storage zx:work s2_rail.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work s2_rail.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work s2_rail.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work s2_rail.u3 int 1 run scoreboard players get @s manacore.u3
function sweetdream:equipment/staff/magic_theory/reset with storage zx:work s2_rail
playsound minecraft:block.respawn_anchor.charge player @s ~ ~ ~ .7 1.4
