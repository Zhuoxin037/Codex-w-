tag @s add sd.hk.current_body
execute unless entity @s[tag=sd.hk.v3] run function sweetdream:boss/husk/migrate_v3
execute unless entity @s[tag=sd.hk.size_15] run function sweetdream:boss/husk/resize
execute store result score @s sdh.hp1000 run data get entity @s Health 1000
scoreboard players operation @s sdh.hp = @s sdh.hp1000
scoreboard players operation @s sdh.hp /= #1000 sdh.tmp
execute if score @s sdh.hp1000 matches ..0 as @e[tag=sd.hk.current_rig,distance=0..,limit=1] run function sweetdream:boss/husk/death/start
execute if entity @e[tag=sd.hk.current_rig,tag=sd.hk.dead,distance=0..,limit=1] run return run tag @s remove sd.hk.current_body
execute store result storage sweetdream:husk args.id int 1 run scoreboard players get @s sdh.id
function sweetdream:boss/husk/bar/update with storage sweetdream:husk args
execute if entity @s[tag=zx.stop] run tag @e[tag=sd.hk.current_rig,distance=0..,limit=1] add sd.hk.frozen
execute if entity @s[tag=zx.stop] run return run tag @s remove sd.hk.current_body
function sweetdream:boss/husk/hurt/read
function sweetdream:boss/husk/reflection/process
execute if score @s sdh.rest matches 1.. run scoreboard players remove @s sdh.rest 1
execute if score @s sdh.bigcd matches 1.. run scoreboard players remove @s sdh.bigcd 1
execute if score @s sdh.smallcd matches 1.. run scoreboard players remove @s sdh.smallcd 1
execute unless score @s sdh.air matches 1 run function sweetdream:boss/husk/ground/tick
function sweetdream:boss/husk/target/tick
function sweetdream:boss/husk/dispatch
execute at @s rotated ~ 0 positioned ^0.103125 ^0 ^0.1875 run tp @e[tag=sd.hk.current_rig,distance=0..,limit=1] ~ ~ ~ ~ 0
tag @e[tag=sd.hk.target,distance=0..] remove sd.hk.target
tag @s remove sd.hk.current_body
