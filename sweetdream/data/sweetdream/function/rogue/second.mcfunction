execute as @a[tag=zx.rg_pending,tag=!zx.rg_active,tag=!zx.rg_wait,tag=!zx.rg_prep] at @s run function sweetdream:rogue/map/return_pending
execute as @a[tag=zx.rg_active] run scoreboard players enable @s zx.rg_tg
execute as @a[tag=zx.rg_prep] run scoreboard players enable @s zx.rg_tg
execute in sweetdream:rogue_preview as @e[type=minecraft:item,distance=0..] if data entity @s Item.components."minecraft:custom_data"{rg_map:1b} run kill @s
function sweetdream:rogue/prototype/maybe_unload
