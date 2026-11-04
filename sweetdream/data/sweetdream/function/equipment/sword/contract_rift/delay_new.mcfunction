summon minecraft:marker ~ ~ ~ {Tags:["zx.cr_delay","zx.cr_new"],data:{}}
data modify entity @e[tag=zx.cr_new,distance=0..,limit=1] data set from storage zx:work cr_delay
scoreboard players operation @e[tag=zx.cr_new,distance=0..,limit=1] zx.cr_due = #now manacore.meta
scoreboard players add @e[tag=zx.cr_new,distance=0..,limit=1] zx.cr_due 10
tag @e[tag=zx.cr_new,distance=0..] remove zx.cr_new
