execute store result storage zx:work jhit.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work jhit.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work jhit.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work jhit.u3 int 1 run scoreboard players get @s manacore.u3
execute if score @s zx.job matches 1 run function fallendream:profession/mage/imbue_hit
execute if data storage zx:combat events[-1].event{kind:"melee"} if score @s zx.job matches 4 run function fallendream:profession/twin/melee
$tag $(vx_uuid) remove zx.victim
