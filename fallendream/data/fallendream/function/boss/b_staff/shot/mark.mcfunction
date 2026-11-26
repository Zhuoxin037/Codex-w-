function fallendream:boss/b_staff/shot/setup
scoreboard players operation #damage bs.dmg = #mark_ground bs.cfg
scoreboard players set #limit bs.limit 1
scoreboard players set #interval bs.interval 0
execute at @e[tag=sd.bs.target,distance=0..,limit=1] run function fallendream:boss/b_staff/fx/new {model:"glyph",kind:2}
execute as @e[tag=sd.bs.newfx,distance=0..,limit=1] at @s run function fallendream:boss/b_staff/fx/project_ground
data merge entity @e[tag=sd.bs.newfx,distance=0..,limit=1] {transformation:{scale:[1.5f,1f,1.5f]}}
scoreboard players set @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.life 28
tag @e[tag=sd.bs.newfx,distance=0..] remove sd.bs.newfx
