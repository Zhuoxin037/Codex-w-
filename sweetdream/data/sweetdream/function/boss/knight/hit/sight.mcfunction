scoreboard players set @s sdk.clear 0
scoreboard players set @s sdk.ray 0
execute at @e[tag=sd.kn.current_body,distance=0..,limit=1] positioned ~ ~1.25 ~ facing entity @s eyes run function sweetdream:boss/knight/hit/ray
execute if score @s sdk.clear matches 1 run function sweetdream:boss/knight/hit/deal with storage sweetdream:knight damage
