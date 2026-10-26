# Previous storage used prevented damage; do not carry it into the new actual-damage formula.
scoreboard players set @s sdh.bigcd 0
scoreboard players set @s sdh.smallcd 0
scoreboard players set @s sdh.speed 0
scoreboard players set @s sdh.walktempo 0
scoreboard players set @s sdh.air 0
scoreboard players set @s sdh.energy 0
scoreboard players set @s sdh.state 0
scoreboard players set @s sdh.age 0
data merge entity @s {NoGravity:0b,Motion:[0d,0d,0d]}
function sweetdream:boss/husk/ward/normal
execute as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function sweetdream_boss:husk/animations/combat_idle/play_exclusive
tag @s add sd.hk.v3
