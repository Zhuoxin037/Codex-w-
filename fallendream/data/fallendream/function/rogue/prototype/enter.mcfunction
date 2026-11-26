execute store result score #rd_restore_ok zx.meta run function fallendream:rogue/prep/restore_off
execute unless score #rd_restore_ok zx.meta matches 1 run return 0
tag @s remove zx.rg_prep
tag @s remove zx.rg_wait
tag @s add zx.rg_active
execute in fallendream:rogue_preview run tp @s 0.5 81 48.5 -90 0
execute at @s run function fallendream:rogue/map/locate
execute at @s run function fallendream:rogue/map/repair
tellraw @s [{"text":"本层已生成。按9查看地图，空副手时双手展开。","color":"aqua"},{"text":"[退出]","color":"gold","click_event":{"action":"run_command","command":"/trigger zx.rg_tg"}}]
scoreboard players enable @s zx.rg_tg
