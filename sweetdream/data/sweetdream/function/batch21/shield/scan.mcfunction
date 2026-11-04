execute store result score #s2_due zx.meta run data get storage zx:work s2_queue[0].end
execute store result score #s2_amount zx.meta run data get storage zx:work s2_queue[0].amount
execute if score #s2_due zx.meta <= #now manacore.meta run scoreboard players operation #s2_expired zx.meta += #s2_amount zx.meta
execute if score #s2_due zx.meta > #now manacore.meta if score #s2_amount zx.meta matches 1.. run data modify storage zx:work s2_keep append from storage zx:work s2_queue[0]
data remove storage zx:work s2_queue[0]
execute if data storage zx:work s2_queue[0] run function sweetdream:batch21/shield/scan
