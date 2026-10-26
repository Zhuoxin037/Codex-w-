tag @e[tag=zx.debug_aim,distance=0..] remove zx.debug_aim
scoreboard players set #debug_ray zx.meta 0
execute anchored eyes positioned ^ ^ ^0.25 run function sweetdream:debug/mark_ray
$execute if entity @e[tag=zx.debug_aim,distance=0..,limit=1] run function sweetdream:tag/mark {target:"@e[tag=zx.debug_aim,distance=0..,limit=1]",mark:"$(mark)"}
$execute if entity @e[tag=zx.debug_aim,distance=0..,limit=1] run tellraw @s [{text:"[调试] 已为 ",color:"green"},{selector:"@e[tag=zx.debug_aim,distance=0..,limit=1]"},{text:" 附加「$(label)」。",color:"green"}]
execute unless entity @e[tag=zx.debug_aim,distance=0..,limit=1] run tellraw @s {text:"[调试] 32格内未瞄准可附加标签的生物。",color:"gray"}
tag @e[tag=zx.debug_aim,distance=0..] remove zx.debug_aim
