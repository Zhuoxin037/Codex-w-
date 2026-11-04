execute if entity @s[tag=zx.thp_on] run attribute @s minecraft:max_absorption modifier remove sweetdream:thp_cap
effect clear @s minecraft:absorption
scoreboard players set #s2_fourthousand zx.meta 4000
scoreboard players operation #s2_amp zx.meta = #s2_target zx.meta
scoreboard players add #s2_amp zx.meta 3999
scoreboard players operation #s2_amp zx.meta /= #s2_fourthousand zx.meta
scoreboard players operation #s2_mod zx.meta = #s2_amp zx.meta
scoreboard players operation #s2_mod zx.meta *= #s2_fourthousand zx.meta
scoreboard players operation #s2_mod zx.meta -= #s2_target zx.meta
scoreboard players set #s2_neg zx.meta -1
scoreboard players operation #s2_mod zx.meta *= #s2_neg zx.meta
scoreboard players remove #s2_amp zx.meta 1
data modify storage zx:work s2_abs_apply set value {amp:0,mod:0.0}
execute store result storage zx:work s2_abs_apply.amp int 1 run scoreboard players get #s2_amp zx.meta
execute store result storage zx:work s2_abs_apply.mod double .001 run scoreboard players get #s2_mod zx.meta
function sweetdream:lib/thp/apply with storage zx:work s2_abs_apply
scoreboard players operation @s zx.thp = #s2_target zx.meta
scoreboard players add @s zx.thp 999
scoreboard players operation @s zx.thp /= #1000 zx.meta
execute unless score @s zx.thp_end > #now manacore.meta run scoreboard players operation @s zx.thp_end = #now manacore.meta
execute unless score @s zx.thp_end > #now manacore.meta run scoreboard players add @s zx.thp_end 1200
