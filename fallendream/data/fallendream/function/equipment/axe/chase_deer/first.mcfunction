tag @e[tag=zx.s2_deer_target,distance=..12] remove zx.s2_deer_target
scoreboard players set #s2_deer_step zx.meta 0
execute anchored eyes positioned ^ ^ ^ run function fallendream:equipment/axe/chase_deer/ray
execute unless entity @e[tag=zx.s2_deer_target,distance=..11,limit=1] run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:chase_deer",mana:360.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:360.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:chase_deer",cooldown_seconds:35.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
scoreboard players set @s zx.s2_stage 1
scoreboard players set @s zx.s2_loss 0
execute store result score @s zx.s2_deer_max run attribute @s minecraft:max_health get 1000
scoreboard players operation @s zx.s2_stage_end = #now manacore.meta
scoreboard players add @s zx.s2_stage_end 40
scoreboard players set #s2_deer_step zx.meta 0
execute at @s facing entity @e[tag=zx.s2_deer_target,distance=..11,limit=1] feet run function fallendream:equipment/axe/chase_deer/dash
execute at @s if entity @e[tag=zx.s2_deer_target,distance=..1.3,limit=1] run function fallendream:equipment/axe/chase_deer/first_hit
tag @e[tag=zx.s2_deer_target,distance=..12] remove zx.s2_deer_target
