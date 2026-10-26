scoreboard players set #lr_refs zx.meta 0
$execute in minecraft:overworld as @e[tag=zx.lr_record,distance=0..,scores={zx.sid=$(tid)}] run scoreboard players add #lr_refs zx.meta 1
$execute in minecraft:the_nether as @e[tag=zx.lr_record,distance=0..,scores={zx.sid=$(tid)}] run scoreboard players add #lr_refs zx.meta 1
$execute in minecraft:the_end as @e[tag=zx.lr_record,distance=0..,scores={zx.sid=$(tid)}] run scoreboard players add #lr_refs zx.meta 1
scoreboard players operation @s zx.lr_live = #lr_refs zx.meta
execute unless score #lr_refs zx.meta matches 1.. run tag @s remove zx.lr_watch
