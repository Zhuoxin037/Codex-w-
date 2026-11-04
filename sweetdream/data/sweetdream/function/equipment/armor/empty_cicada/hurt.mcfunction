scoreboard players add @s zx.s2_cicada_cd 0
execute if score @s zx.s2_cicada_cd > #now manacore.meta run return 0
scoreboard players operation @s zx.s2_cicada_cd = #now manacore.meta
scoreboard players add @s zx.s2_cicada_cd 320
data modify storage zx:work s2_shadow set value {owner:"",u0:0,u1:0,u2:0,u3:0}
function sweetdream:lib/uuid
data modify storage zx:work s2_shadow.owner set from storage zx:data self.uuid
execute store result storage zx:work s2_shadow.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work s2_shadow.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work s2_shadow.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work s2_shadow.u3 int 1 run scoreboard players get @s manacore.u3
summon minecraft:marker ~ ~ ~ {Tags:["zx.s2_cicada","zx.s2_shadow_new"],data:{}}
data modify entity @e[tag=zx.s2_shadow_new,distance=..1,limit=1] data set from storage zx:work s2_shadow
scoreboard players operation @e[tag=zx.s2_shadow_new,distance=..1,limit=1] zx.s2_end = #now manacore.meta
scoreboard players add @e[tag=zx.s2_shadow_new,distance=..1,limit=1] zx.s2_end 80
tag @e[tag=zx.s2_shadow_new,distance=..1] remove zx.s2_shadow_new
