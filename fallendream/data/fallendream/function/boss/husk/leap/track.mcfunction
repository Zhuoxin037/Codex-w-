execute unless data entity @s data{valid:1b} run return 0
function fallendream:lib/u_by with entity @s data
execute at @a[tag=zx.ub,gamemode=!creative,gamemode=!spectator,distance=..36,limit=1] run tp @s ~ ~ ~
scoreboard players set @s sdh.jumpsteps 24
execute at @s run function fallendream:boss/husk/leap/project_ground
