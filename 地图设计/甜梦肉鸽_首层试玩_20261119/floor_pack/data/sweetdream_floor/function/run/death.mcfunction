execute unless score #phase sd.floor matches 9 run title @s title {"text":"梦境崩散","color":"red"}
execute unless score #phase sd.floor matches 9 run function sweetdream_floor:combat/clean
scoreboard players set #phase sd.floor 9
execute if entity @s[x=-68,y=88,z=34,dx=30,dy=12,dz=28] run function sweetdream_floor:run/exit
