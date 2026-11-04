data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=3},distance=0..,limit=1] run return run kill @s
function sweetdream:equipment/staff/chorus/voice_check with entity @s data
execute unless entity @s[tag=zx.cs_voice] run tag @s add zx.j_return
execute if entity @s[tag=zx.cs_voice] run particle minecraft:note ~ ~1 ~ .2 .35 .2 0 1 force
execute if entity @s[tag=zx.cs_voice] run effect give @e[type=!#sweetdream:no_damage,distance=..3] minecraft:slowness 1 2 true
