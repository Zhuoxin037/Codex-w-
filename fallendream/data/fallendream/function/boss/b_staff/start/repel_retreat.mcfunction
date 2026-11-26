function fallendream:boss/b_staff/start/common
scoreboard players set @s bs.state 14
scoreboard players set @s bs.cd 240
scoreboard players set @s bs.near 0
function fallendream:boss/b_staff/probe/start
execute if score @s bs.path matches 0 run scoreboard players set @s bs.state 16
