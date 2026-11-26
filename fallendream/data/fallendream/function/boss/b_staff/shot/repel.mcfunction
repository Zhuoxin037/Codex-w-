function fallendream:boss/b_staff/shot/setup
scoreboard players operation #damage bs.dmg = #repel_retreat bs.cfg
scoreboard players set #limit bs.limit 1
scoreboard players set #interval bs.interval 0
execute positioned ~ ~0.15 ~ run function fallendream:boss/b_staff/fx/new {model:"glyph",kind:4}
data merge entity @e[tag=sd.bs.newfx,distance=0..,limit=1] {transformation:{scale:[2.5f,1f,2.5f]}}
scoreboard players set @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.life 14
tag @e[tag=sd.bs.newfx,distance=0..] remove sd.bs.newfx
