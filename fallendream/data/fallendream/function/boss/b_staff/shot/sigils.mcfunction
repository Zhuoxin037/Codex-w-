function fallendream:boss/b_staff/shot/setup
scoreboard players set #damage bs.dmg 0
scoreboard players set #limit bs.limit 0
scoreboard players set #interval bs.interval 0
execute positioned ^-0.9375 ^2.125 ^0.4375 run function fallendream:boss/b_staff/fx/new {model:"sigil",kind:5}
data modify entity @e[tag=sd.bs.newfx,distance=0..,limit=1] Rotation set from entity @s Rotation
scoreboard players set @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.dir -1
scoreboard players set @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.life 36
tag @e[tag=sd.bs.newfx,distance=0..] add sd.bs.sigil
tag @e[tag=sd.bs.newfx,distance=0..] remove sd.bs.newfx
execute positioned ^0.9375 ^2.125 ^0.4375 run function fallendream:boss/b_staff/fx/new {model:"sigil",kind:5}
data modify entity @e[tag=sd.bs.newfx,distance=0..,limit=1] Rotation set from entity @s Rotation
scoreboard players set @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.dir 1
scoreboard players set @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.life 36
tag @e[tag=sd.bs.newfx,distance=0..] add sd.bs.sigil
tag @e[tag=sd.bs.newfx,distance=0..] remove sd.bs.newfx
