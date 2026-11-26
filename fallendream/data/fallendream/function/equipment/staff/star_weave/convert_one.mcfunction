execute unless score @s zx.weave_until > #now manacore.meta run return run kill @s
function fallendream:equipment/staff/star_weave/mark_follow with entity @s data
execute unless entity @s[tag=zx.weave_mark] run return 0
execute at @s run summon minecraft:marker ~ ~ ~ {Tags:["zx.weave_point","zx.weave_new"],data:{}}
data modify entity @e[tag=zx.weave_new,distance=0..,limit=1] data set from storage zx:work weavefield
scoreboard players add #weave_index zx.meta 1
scoreboard players operation @e[tag=zx.weave_new,distance=0..,limit=1] zx.weave_idx = #weave_index zx.meta
tag @e[tag=zx.weave_new,distance=0..] remove zx.weave_new
kill @s
