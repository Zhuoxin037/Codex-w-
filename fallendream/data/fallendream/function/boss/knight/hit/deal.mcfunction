$execute store success score @s zx.rt_hit run damage @s $(amount) fallendream:knight_blade by @e[tag=sd.kn.current_body,distance=0..,limit=1]
execute if score @s zx.rt_hit matches 1 run function fallendream:equipment/tool/retro_shine/from_entity {source:"@e[tag=sd.kn.current_body,distance=0..,limit=1]"}
