execute store result storage sweetdream:husk args.id int 1 run scoreboard players get @s sdh.id
function sweetdream:boss/husk/leap/clean with storage sweetdream:husk args
tag @a[tag=sd.hk.leap_player] remove sd.hk.leap_player
scoreboard players set #found sdh.tmp 0
data modify storage sweetdream:husk leap_player set value {valid:0b}
execute as @a[gamemode=!creative,gamemode=!spectator,distance=..30,sort=nearest] run function sweetdream:boss/husk/leap/pick_player
function sweetdream:boss/husk/leap/markers with storage sweetdream:husk args
data merge entity @s {NoGravity:1b,Motion:[0d,0d,0d]}
scoreboard players set @s sdh.air 1
scoreboard players set @s sdh.state 41
scoreboard players set @s sdh.age 0
execute as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function sweetdream_boss:husk/animations/leap_air/play_exclusive
tag @a[tag=sd.hk.leap_player] remove sd.hk.leap_player
