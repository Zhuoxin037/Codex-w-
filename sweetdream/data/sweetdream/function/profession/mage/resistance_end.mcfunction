execute unless score @s zx.j_res_active matches 1 run return 0
scoreboard players set @s zx.j_res_active 0
data remove storage zx:work jr_current
data modify storage zx:work jr_current set from entity @s active_effects[{id:"minecraft:resistance"}]
scoreboard players set #jr_amp zx.meta -1
scoreboard players set #jr_duration zx.meta 0
execute store result score #jr_amp zx.meta run data get storage zx:work jr_current.amplifier
execute store result score #jr_duration zx.meta run data get storage zx:work jr_current.duration
# Preserve a stronger/longer effect gained from another source while the choice was open.
execute unless score #jr_amp zx.meta matches 1 run return 0
execute unless score #jr_duration zx.meta matches 0..20 run return 0
effect clear @s minecraft:resistance
function sweetdream:lib/uuid
data modify storage zx:work jr.uuid set from storage zx:data self.uuid
function sweetdream:profession/mage/resistance_restore with storage zx:work jr
