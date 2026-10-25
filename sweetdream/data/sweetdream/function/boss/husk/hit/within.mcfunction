$execute at @e[tag=sd.hk.current_body,distance=0..,limit=1] unless entity @s[distance=..$(cap)] run return 0
scoreboard players set @s sdh.clear 0
scoreboard players set @s sdh.ray 0
execute at @e[tag=sd.hk.current_body,distance=0..,limit=1] positioned ~ ~1.2 ~ facing entity @s eyes run function sweetdream:boss/husk/hit/ray
execute if score @s sdh.clear matches 1 run function sweetdream:boss/husk/hit/deal with storage sweetdream:husk damage
