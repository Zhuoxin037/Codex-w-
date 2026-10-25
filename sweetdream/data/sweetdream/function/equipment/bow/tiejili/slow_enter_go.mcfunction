$execute if entity @e[type=marker,tag=zx.tjl_lease_$(id)] run return 0
# A chunk-unloaded target can outlive its lease. Remove only our recognizable previous effect.
execute if entity @s[tag=zx.tjl_managed] if data entity @s active_effects[{id:"minecraft:slowness",amplifier:1,ambient:1b,show_icon:0b}] run effect clear @s minecraft:slowness
tag @s add zx.tjl_managed
$tag @s add zx.tjl_target_$(id)
$summon marker ~ ~ ~ {Tags:["zx.tjl_lease","zx.tjl_lease_$(id)"],data:{fx:{id:$(id),started:0,original:{}}}}
$execute store result entity @e[type=marker,tag=zx.tjl_lease_$(id),limit=1] data.fx.started int 1 run scoreboard players get #now manacore.meta
$data modify entity @e[type=marker,tag=zx.tjl_lease_$(id),limit=1] data.fx.original set from entity @s active_effects[{id:"minecraft:slowness"}]
