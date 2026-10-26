scoreboard players set @s zx.j_pulse 5
tag @s add zx.j_taunt_body
data modify storage zx:work jbody_target set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work jbody_target.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work jbody_target.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work jbody_target.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work jbody_target.u3 int 1 run data get entity @s UUID[3]
execute as @e[type=#sweetdream:living,type=!minecraft:player,tag=!zx.j_body,tag=!zx.j_twin,distance=..16] at @s run function sweetdream:profession/twin/taunt
tag @s remove zx.j_taunt_body
