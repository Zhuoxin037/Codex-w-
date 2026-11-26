scoreboard players set @s bs.dir 0
execute if score @s bs.rest matches 1.. run return run scoreboard players remove @s bs.rest 1
execute unless entity @e[tag=sd.bs.target,distance=0..,limit=1] run return 0
function fallendream:boss/b_staff/face
execute if entity @e[tag=sd.bs.target,distance=..3,limit=1] run scoreboard players add @s bs.near 1
execute unless entity @e[tag=sd.bs.target,distance=..3,limit=1] run scoreboard players set @s bs.near 0
execute if score @s bs.near matches 20.. if score @s bs.cd matches 0 run return run function fallendream:boss/b_staff/start/repel_retreat
execute if score @s bs.near matches 1..19 if score @s bs.cd matches 0 run return 0
execute if entity @e[tag=sd.bs.target,distance=16.01..,limit=1] run return run function fallendream:boss/b_staff/move/forward
execute if entity @e[tag=sd.bs.target,distance=..6.99,limit=1] run return run function fallendream:boss/b_staff/move/backward
function fallendream:boss/b_staff/choose
