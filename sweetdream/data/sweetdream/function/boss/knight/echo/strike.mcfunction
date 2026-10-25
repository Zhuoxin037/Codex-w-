$tag @e[tag=sd.kn.body,scores={sdk.id=$(owner)},distance=0..,limit=1] add sd.kn.current_body
tag @s add sd.kn.current_trace
execute as @e[tag=sd.kn.current_body,distance=0..,limit=1] at @s run function sweetdream:boss/knight/target/tick
execute positioned ~-0.65 ~-0.75 ~-0.65 as @a[gamemode=!creative,gamemode=!spectator,dx=1.3,dy=1.5,dz=1.3] run function sweetdream:boss/knight/echo/hit
execute positioned ~-0.65 ~-0.75 ~-0.65 as @e[tag=sd.kn.target,type=!minecraft:player,dx=1.3,dy=1.5,dz=1.3] run function sweetdream:boss/knight/echo/hit
particle minecraft:dust{color:[0.8,0.74,0.95],scale:0.7} ~ ~ ~ 0.1 0.5 0.1 0 6 normal
tag @e[tag=sd.kn.current_body,distance=0..] remove sd.kn.current_body
tag @e[tag=sd.kn.target,distance=0..] remove sd.kn.target
tag @s remove sd.kn.current_trace
