data modify storage zx:work jb_owner set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work jb_owner.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work jb_owner.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work jb_owner.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work jb_owner.u3 int 1 run scoreboard players get @s manacore.u3
function sweetdream:lib/rnd
scoreboard players operation #jbmark zx.meta = #rnd zx.meta
scoreboard players operation #jbmark zx.meta %= #j5 zx.meta
execute if score #jbmark zx.meta matches 0 as @e[type=!#sweetdream:no_damage,distance=..4] at @s run function sweetdream:profession/mage/bloom_mark {mark:"liuhuo"}
execute if score #jbmark zx.meta matches 1 as @e[type=!#sweetdream:no_damage,distance=..4] at @s run function sweetdream:profession/mage/bloom_mark {mark:"yehuo"}
execute if score #jbmark zx.meta matches 2 as @e[type=!#sweetdream:no_damage,distance=..4] at @s run function sweetdream:profession/mage/bloom_mark {mark:"shixin"}
execute if score #jbmark zx.meta matches 3 as @e[type=!#sweetdream:no_damage,distance=..4] at @s run function sweetdream:profession/mage/bloom_mark {mark:"yuanhai"}
execute if score #jbmark zx.meta matches 4 as @e[type=!#sweetdream:no_damage,distance=..4] at @s run function sweetdream:profession/mage/bloom_mark {mark:"dream"}
