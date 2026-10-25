$execute store success score @s zx.rt_hit run damage @s $(amount) minecraft:mob_attack by @e[tag=sd.fb.current_body,limit=1,distance=0..]
execute if score @s zx.rt_hit matches 1 run function sweetdream:equipment/tool/retro_shine/from_entity {source:"@e[tag=sd.fb.current_body,limit=1,distance=0..]"}
return run scoreboard players get @s zx.rt_hit
