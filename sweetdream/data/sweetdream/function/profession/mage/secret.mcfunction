scoreboard players set @s zx.j_seen 0
scoreboard players set @s zx.j_grace 1
function sweetdream:profession/mage/pain_enqueue {no_self:1}
scoreboard players set @s zx.j_sorrow 2
effect give @e[type=!#sweetdream:no_damage,distance=..6] minecraft:slowness 8 1 true
function sweetdream:profession/mage/p_rebirth
function sweetdream:profession/mage/p_bloom
scoreboard players set @s zx.j_orb 3
execute if score @s zx.j_aw matches 1 run scoreboard players set @s zx.j_orb 5
tellraw @s {"text":"五种预言齐聚：隐秘的「预言」！","color":"gold"}

scoreboard players operation @s zx.j_pain_book = @s zx.j_fs_book
scoreboard players operation @s zx.j_pain_sor = @s zx.j_fs_sor

scoreboard players operation @s zx.j_pain_end = #now manacore.meta
scoreboard players add @s zx.j_pain_end 160
