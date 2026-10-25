$execute if data storage sweetdream:knight waves."$(id)".echo_hits[{uuid:$(uuid)}] run return 0
scoreboard players set @s sdk.clear 0
scoreboard players set @s sdk.ray 0
execute at @e[tag=sd.kn.current_trace,distance=0..,limit=1] facing entity @s eyes run function sweetdream:boss/knight/hit/ray
execute unless score @s sdk.clear matches 1 run return 0
$execute unless data storage sweetdream:knight waves."$(id)".echo_hits run data modify storage sweetdream:knight waves."$(id)".echo_hits set value []
$data modify storage sweetdream:knight waves."$(id)".echo_hits append value {uuid:$(uuid)}
execute store success score @s zx.rt_hit run damage @s 6 minecraft:mob_attack by @e[tag=sd.kn.current_body,distance=0..,limit=1]
execute if score @s zx.rt_hit matches 1 run function sweetdream:equipment/tool/retro_shine/from_entity {source:"@e[tag=sd.kn.current_body,distance=0..,limit=1]"}
